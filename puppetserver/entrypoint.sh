#!/usr/bin/env bash
# Puppet Server Entry Point
# @author Vlad Ghinea

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
SSLDIR='/etc/puppetlabs/puppet/ssl'

# Fix SSL directory ownership
mkdir -p "$SSLDIR"
chown -R puppet:puppet "$SSLDIR"

exec "$@"
