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

# Configure Puppet for PuppetDB
if [[ "${PUPPETDB:-false}" == 'true' ]]; then
  puppet config set storeconfigs_backend puppetdb --section master && \
  puppet config set storeconfigs true --section master && \
  puppet config set reports puppetdb --section master
fi

# Configure Puppet to use a certificate autosign script (if it exists)
AUTOSIGN="${AUTOSIGN:-}"
if [[ -n "$AUTOSIGN" ]]; then
  puppet config set autosign "$AUTOSIGN" --section master
fi

# Configure Puppet to use a comma-separated list of alternate DNS names (if they exist)
DNS_ALT_NAMES="${DNS_ALT_NAMES:-}"
if [[ -n "$DNS_ALT_NAMES" ]]; then
  puppet config set dns_alt_names "$DNS_ALT_NAMES" --section master
fi

exec "$@"
