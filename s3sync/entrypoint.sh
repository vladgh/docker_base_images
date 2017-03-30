#!/usr/bin/env bash
# S3Sync Entry Point

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
S3PATH=${S3PATH:-}
WATCHDIR=${WATCHDIR:-}
CRON_TIME="${CRON_TIME:-}"
DESTINATION=${DESTINATION:-/sync}

# Log message
log(){
  echo "[$(date "+%Y-%m-%dT%H:%M:%S%z") - $(hostname)] ${*}"
}

# Sync files
sync_files(){
  local src="${1:-}"
  local dst="${2:-}"

  mkdir -p "$dst"

  log "Sync '${src}' to '${dst}'"
  if ! aws s3 sync --delete --exact-timestamps "$src" "$dst"; then
    log "Could not sync '${src}' to '${dst}'" >&2; exit 1
  fi
}

# Watch directory
watch_directory(){
  log "Watching directory '${WATCHDIR}' for changes"
  inotifywait \
    --event create \
    --event delete \
    --event modify \
    --event move \
    --format "%e %w%f" \
    --monitor \
    --quiet \
    --recursive \
    "$WATCHDIR" |
  while read -r CHANGED
  do
    log "$CHANGED"
    sync_files "$WATCHDIR" "$S3PATH"
  done
}

# Install cron job
run_cron(){
  log "Setup the cron job (${CRON_TIME})"
  echo "${CRON_TIME} /entrypoint.sh once" > /etc/crontabs/root
  exec crond -f -l 6
}

# Main function
main(){
  if [[ ! "$S3PATH" =~ s3:// ]]; then
    log 'No S3PATH specified' >&2; exit 1
  fi

  # Run initial sync
  sync_files "$S3PATH" "$DESTINATION"

  # Exit if argument is 'once'
  if [[ "${*:-}" == 'once' ]]; then exit; fi

  # Setup inotify or cron job
  if [[ -n "$WATCHDIR" ]]; then
    watch_directory
  elif [[ -n "$CRON_TIME" ]]; then
    run_cron
  fi
}

main "$@"
