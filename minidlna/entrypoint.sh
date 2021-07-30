#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
TZ="${TZ:-}"
PUID="${PUID:-100}"
PGID="${PGID:-101}"
PIDFILE="/minidlna/minidlna.pid"

# Remove old pid if it exists
[ -f $PIDFILE ] && rm -f $PIDFILE

# Change user and group identifier
groupmod --non-unique --gid "$PGID" minidlna
usermod --non-unique --uid "$PUID" minidlna

if [[ -n "$TZ" ]]; then
  echo 'Set timezone'
  setup-timezone -z "$TZ"
fi
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
echo "db_dir=/minidlna/cache" >> /etc/minidlna.conf
echo "log_dir=/minidlna/" >>/etc/minidlna.conf

# Set permissions
mkdir -p /minidlna/cache
chown -R "${PUID}:${PGID}" /minidlna

# Set timezone
setup-timezone -z "$TZ"

# Start daemon
exec su-exec minidlna /usr/sbin/minidlnad -P "$PIDFILE" -S "$@"
