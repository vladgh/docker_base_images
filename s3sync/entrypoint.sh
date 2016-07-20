#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
S3PATH=${S3PATH:-}
WATCHDIR=${WATCHDIR:-/watch}
INTERVAL=${INTERVAL:-600}
EVENTS=${EVENTS:-'CREATE,DELETE,MODIFY,MOVE,MOVED_FROM,MOVED_TO'}

log(){
  echo "[$(date "+%Y-%m-%dT%H:%M:%S%z") - $(hostname)] ${*}"
}

sanity_checks() {
  mkdir -p "$WATCHDIR" # Ensure watched directory exists

  if [[ ! "${S3PATH:-}" =~ s3:// ]]; then
    log 'No S3 path specified' >&2; exit 1
  fi
  if [[ ! "${INTERVAL:-}" =~ ^[0-9]+$ ]]; then
    log 'The INTERVAL is not an integer' >&2; exit 1
  fi
}

sync_down(){
  log 'Downloading files...'
  aws s3 sync --delete "$S3PATH" "$WATCHDIR" || true
}

sync_up(){
  log 'Uploading files...'
  aws s3 sync --delete "$WATCHDIR" "$S3PATH" || true
}

sync_event(){
  case "$@" in
    DELETE* | MOVED_FROM*)
      sync_up
      ;;
    *)
      sync_up
      ;;
  esac
}

cleanup() {
  log 'Exit detected; trying to run final sync'
  sync_up; exit "${1:-0}"
}

main(){
  # Sanity checks
  sanity_checks

  # Trap exit
  trap 'cleanup $?' HUP INT QUIT TERM

  # Initial download
  sync_down

  # Watch
  inotifywait -e "$EVENTS" -m -r --format '%:e %f' "$WATCHDIR" | (
    while true; do read -r -t 1 EVENT && sync_event "$EVENT"; unset EVENT; done
  ) & (
    while true; do sync_up; sleep "$INTERVAL" & wait ${!}; done
  )
}

main
