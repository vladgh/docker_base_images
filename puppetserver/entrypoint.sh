#!/usr/bin/env bash
# Puppet Server Entry Point
# @author Vlad Ghinea

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
SSLDIR='/etc/puppetlabs/puppet/ssl'
CSR_SIGN="${SSLDIR}/ca/csr_sign"

# Fix SSL directory ownership
mkdir -p "$SSLDIR"
chown -R puppet:puppet "$SSLDIR"

# Configure puppet to use a certificate autosign script (if it exists)
if [[ -x "$CSR_SIGN" ]]; then
  puppet config set autosign "$CSR_SIGN" --section master
fi

exec "$@"
