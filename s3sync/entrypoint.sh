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

# Sync event
sync_event(){
  case "$@" in
    DELETE* | MOVED_FROM*)
      sync_files "$WATCHDIR" "$S3PATH"
      ;;
    *)
      sync_files "$WATCHDIR" "$S3PATH"
      ;;
  esac
}

# Watch directory
watch_directory(){
  inotifywait -e 'CREATE,DELETE,MODIFY,MOVE,MOVED_FROM,MOVED_TO' -m -r --format '%:e %f' "$WATCHDIR" | (
    while true; do read -r -t 1 EVENT && sync_event "$EVENT"; unset EVENT; done
  )
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
