#!/usr/bin/env bash
# PuppetDB Entry Point
# @author Vlad Ghinea

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# Generate Puppet Certificates
if [[ ! -s "$(puppet config print hostcert)" ]] && \
  [[ ! -s "$(puppet config print hostprivkey)" ]] && \
  [[ ! -s "$(puppet config print localcacert)" ]]
then
  echo 'Waiting for Puppet Server...'
  while ! nc -z puppet 8140; do
    sleep 1
  done
  puppet config set certname "$(hostname)" --section main
  puppet agent --verbose --onetime --no-daemonize --waitforcert 120
else
  echo 'Puppet certificates already configured'
fi

# Generate PuppetDB certificates
# /etc/puppetlabs/puppetdb/ssl is automatically populated from Puppet certificates
# and doesn't need a separate volume.
puppetdb ssl-setup -f

exec "$@"
