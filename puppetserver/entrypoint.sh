#!/usr/bin/env bash
# Puppet Server Entry Point
# @author Vlad Ghinea

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# Fix volumes ownership
chown -R puppet:puppet /etc/puppetlabs/puppet/ssl

exec "$@"
