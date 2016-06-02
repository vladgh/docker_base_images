#!/usr/bin/env bash
# Puppet Server Entry Point
# @author Vlad Ghinea

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# Fix SSL directory ownership
SSLDIR=$(puppet config print ssldir)
mkdir -p "$SSLDIR"
chown -R puppet:puppet "$SSLDIR"

# Configure puppet to use a certificate autosign script (if it exists)
AUTOSIGN="${AUTOSIGN:-}"
if [[ -n "$AUTOSIGN" ]]; then
  puppet config set autosign "$AUTOSIGN" --section master
fi

exec "$@"
