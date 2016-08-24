#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# Remove old pid if it exists
[ -f /cfg/deluged.pid ] && rm -f /cfg/deluged.pid

# Ensure user is present
useradd -u "$USER_ID" deluge || true

# Ensure the right permissions
chown -R deluge: /cfg

# Start Deluge Daemon
su - deluge -c '/usr/bin/deluged --config /cfg --loglevel info'

# Start Deluge Web UI
su - deluge -c '/usr/bin/deluge-web --config /cfg --loglevel info'
