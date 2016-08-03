#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# Remove old pid if it exists
[ -f /data/deluged.pid ] && rm -f /data/deluged.pid

# Start Deluge Daemon
/usr/bin/deluged --config /config --loglevel info

# Start Deluge Web UI
/usr/bin/deluge-web --config /config --loglevel info
