#!/usr/bin/env bash
set -e

[ -f /data/deluged.pid ] && rm -f /data/deluged.pid
deluged -c /data -L info -l /data/deluged.log
deluge-web -c /data
