#!/usr/bin/env bash
set -e

# Remove old pid if it exists
[ -f /data/deluged.pid ] && rm -f /data/deluged.pid

# Start Deluge Daemon
/usr/bin/deluged --config /data --logfile /data/deluged.log --loglevel info

# Start Deluge Web UI
/usr/bin/deluge-web --config /data --logfile /data/deluge-web.log --loglevel info
