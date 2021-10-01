#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# DEBUG
[ -z "${DEBUG:-}" ] || set -x

# VARs
export TZ="${TZ:-}"
export PUID="${PUID:-100}"
export PGID="${PGID:-101}"
export PIDFILE='/minidlna/minidlna.pid'
export FORCE_SCAN="${FORCE_SCAN:-false}"
export FORCE_REBUILD="${FORCE_REBUILD:-false}"

# Remove old pid if it exists
[ -f "$PIDFILE" ] && rm -f "$PIDFILE"

echo '=== Set user and group identifier'
groupmod --non-unique --gid "$PGID" minidlna
usermod --non-unique --uid "$PUID" minidlna

if [[ -n "$TZ" ]]; then
  echo '=== Set timezone'
  setup-timezone -z "$TZ"
fi

echo '=== Set standard configuration'
export MINIDLNA_DB_DIR="${MINIDLNA_DB_DIR:-/minidlna/cache}"
export MINIDLNA_LOG_DIR="${MINIDLNA_LOG_DIR:-/minidlna}"
export MINIDLNA_INOTIFY="${MINIDLNA_INOTIFY:-yes}"

echo '=== Set configuration from environment variables'
: > /etc/minidlna.conf
for VAR in $(env); do
  if [[ "$VAR" =~ ^MINIDLNA_ ]]; then
    if [[ "$VAR" =~ ^MINIDLNA_MEDIA_DIR ]]; then
      minidlna_name='media_dir'
    else
      minidlna_name=$(echo "$VAR" | sed -r "s/MINIDLNA_(.*)=.*/\\1/g" | tr '[:upper:]' '[:lower:]')
    fi
    minidlna_value=$(echo "$VAR" | sed -r "s/.*=(.*)/\\1/g")
    echo "${minidlna_name}=${minidlna_value}" >> /etc/minidlna.conf
  fi
done

echo '=== Set permissions'
mkdir -p /minidlna/cache
chown -R "${PUID}:${PGID}" /minidlna

echo '=== Generate scan/rebuild flags'
if [[ "$FORCE_SCAN" == true ]]; then
  set -- -r "$@"
fi
if [[ "$FORCE_REBUILD" == true ]]; then
  set -- -R "$@"
fi

echo '=== Start daemon'
exec su-exec minidlna /usr/sbin/minidlnad -P "$PIDFILE" -S "$@"
