#!/usr/bin/env bash
# S3Sync Entry Point

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
S3PATH=${S3PATH:-}
SYNCDIR="${SYNCDIR:-/sync}"
AWS_S3_SSE="${AWS_S3_SSE:-false}"
AWS_S3_SSE_KMS_KEY_ID="${AWS_S3_SSE_KMS_KEY_ID:-}"
CRON_TIME="${CRON_TIME:-10 * * * *}"
INITIAL_DOWNLOAD="${INITIAL_DOWNLOAD:-true}"
SYNCEXTRA="${SYNCEXTRA:-}"
EXCLUDE="${EXCLUDE:-}"

if [[ ! -z $EXCLUDE ]]; then 
  EXCLUDE_FLAG="--exclude=$EXCLUDE";
else
  EXCLUDE_FLAG="";
fi

# Log message
log(){
  echo "[$(date "+%Y-%m-%dT%H:%M:%S%z") - $(hostname)] ${*}"
}

# Sync files
sync_files(){
  local src dst sync_cmd
  src="${1:-}"
  dst="${2:-}"


  sync_cmd="$EXCLUDE_FLAG --no-progress --delete --exact-timestamps $SYNCEXTRA";

  if [[ "$AWS_S3_SSE" == 'true' ]] || [[ "$AWS_S3_SSE" == 'aes256' ]]; then
    s3_upload_cmd+=' --sse AES256'
  elif [[ "$AWS_S3_SSE" == 'kms' ]]; then
    s3_upload_cmd+=' --sse aws:kms'
    if [[ -n "$AWS_S3_SSE_KMS_KEY_ID" ]]; then
      s3_upload_cmd+=" --sse-kms-key-id ${AWS_S3_SSE_KMS_KEY_ID}"
    fi
  fi

  if [[ ! "$dst" =~ s3:// ]]; then
    mkdir -p "$dst" # Make sure directory exists
  fi

  log "Sync '${src}' to '${dst}'"
  log "aws s3 sync \"$src\" \"$dst\" $sync_cmd"
  if ! eval aws s3 sync "$src" "$dst" $sync_cmd; then
    log "Could not sync '${src}' to '${dst}'" >&2; exit 1
  fi
}

# Download files
download_files(){
  sync_files "$S3PATH" "$SYNCDIR"
}

# Upload files
upload_files(){
  sync_files "$SYNCDIR" "$S3PATH"
}

# Run initial download
initial_download(){
  if [[ "$INITIAL_DOWNLOAD" == 'true' ]]; then
    if [[ -d "$SYNCDIR" ]]; then
      # directory exists
      if [[ $(ls -A "$SYNCDIR" 2>/dev/null) ]]; then
        # directory is not empty
        log "${SYNCDIR} is not empty; skipping initial download"
      else
        # directory is empty
      download_files
      fi
    else
      # directory does not exist
    download_files
    fi
  elif [[ "$INITIAL_DOWNLOAD" == 'force' ]]; then
    download_files
  fi
}

# Watch directory using inotify
watch_directory(){
  initial_download # Run initial download

  log "Watching directory '${SYNCDIR}' for changes"
  inotifywait \
    --event create \
    --event delete \
    --event modify \
    --event move \
    --format "%e %w%f" \
    --monitor \
    --quiet \
    --recursive \
    "$EXCLUDE_FLAG" \
    "$SYNCDIR" |
  while read -r changed
  do
    log "$changed"
    upload_files
  done
}

# Install cron job
run_cron(){
  local action="${1:-upload}"

  # Run initial download
  initial_download

  log "Setup the cron job (${CRON_TIME})"
  echo "${CRON_TIME} /entrypoint.sh ${action}" > /etc/crontabs/root
  exec crond -f -l 6
}

# Main function
main(){
  if [[ ! "$S3PATH" =~ s3:// ]]; then
    log 'No S3PATH specified' >&2; exit 1
  fi

  mkdir -p "$SYNCDIR" # Make sure directory exists

  # Parse command line arguments
  cmd="${1:-download}"
  case "$cmd" in
    download)
      download_files
      ;;
    upload)
      upload_files
      ;;
    sync)
      watch_directory
      ;;
    periodic_upload)
      run_cron upload
      ;;
    periodic_download)
      run_cron download
      ;;
    *)
      log "Unknown command: ${cmd}"; exit 1
      ;;
  esac
}

main "$@"
