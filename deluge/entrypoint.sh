#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# Remove old pid if it exists
[ -f /cfg/deluged.pid ] && rm -f /cfg/deluged.pid

# Ensure user is present
groupadd -g "$GROUP_ID" deluge || true
useradd -u "$USER_ID" -g deluge deluge || true

# Ensure config directory exists
mkdir -p /cfg

# Ensure the right permissions
chown -R deluge:deluge /cfg

# Set umask
umask "$UMASK"

# Start Deluge Daemon
su - deluge -c '/usr/bin/deluged --config /cfg --loglevel info'

# Start Deluge Web UI
su - deluge -c '/usr/bin/deluge-web --config /cfg --loglevel info'
