#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

S3PATH=${S3PATH:-}
WATCHDIR=${WATCHDIR:-}
INTERVAL=${INTERVAL:-}
DESTINATION=${DESTINATION:-/sync}

log(){
  echo "[$(date "+%Y-%m-%dT%H:%M:%S%z") - $(hostname)] ${*}"
}

cleanup() {
  log 'Exit detected'; exit 0
}

sync_files(){
  local src="${1:-}"
  local dst="${2:-}"

  mkdir -p "$dst"

  log "Sync '${src}' to '${dst}'"
  if ! aws s3 sync --delete --exact-timestamps "$src" "$dst"; then
    log "Could not sync '${src}' to '${dst}'" >&2; exit 1
  fi
}

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

watch_directory(){
  sync_files "$S3PATH" "$WATCHDIR"

  inotifywait -e 'CREATE,DELETE,MODIFY,MOVE,MOVED_FROM,MOVED_TO' -m -r --format '%:e %f' "$WATCHDIR" | (
    while true; do read -r -t 1 EVENT && sync_event "$EVENT"; unset EVENT; done
  )
}

run_loop(){
  while true; do sync_files "$S3PATH" "$DESTINATION"; sleep "$INTERVAL"; done
}

main(){
  trap 'cleanup $?' HUP INT QUIT TERM

  if [[ ! "$S3PATH" =~ s3:// ]]; then
    log 'No S3PATH specified' >&2; exit 1
  fi

  if [[ -n "$WATCHDIR" ]]; then
    watch_directory
  elif [[ "$INTERVAL" =~ ^[0-9]+$ ]]; then
    run_loop
  else
    sync_files "$S3PATH" "$DESTINATION"
  fi
}

main "$@"
