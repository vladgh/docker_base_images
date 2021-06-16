# PuppetServer Docker Image ([Dockerfile](Dockerfile))

[![badge](https://images.microbadger.com/badges/image/vladgh/puppetserver.svg)](https://microbadger.com/images/vladgh/puppetserver)
[![badge](https://images.microbadger.com/badges/version/vladgh/puppetserver.svg)](https://microbadger.com/images/vladgh/puppetserver)
[![badge](https://images.microbadger.com/badges/commit/vladgh/puppetserver.svg)](https://microbadger.com/images/vladgh/puppetserver)
[![badge](https://images.microbadger.com/badges/license/vladgh/puppetserver.svg)](https://microbadger.com/images/vladgh/puppetserver)

## **⚠️ This project is no longer supported!**

## Available environment variables

### `PUPPETDB` [Boolean]

Configures Puppet Server for PuppetDB. Defaults to `false`

```shell
docker run -d -e PUPPETDB=true vladgh/puppetserver
```

### `AUTOSIGN` [Boolean/String]

Puppet auto signing. For more information regarding policy based auto signing go to <https://docs.puppet.com/puppet/latest/reference/ssl_autosign.html#policy-based-autosigning>

```shell
docker run -d -e AUTOSIGN=true vladgh/puppetserver
docker run -d -e AUTOSIGN=false vladgh/puppetserver
docker run -d -e AUTOSIGN=/usr/local/bin/autosign.sh vladgh/puppetserver
```

### `DNS_ALT_NAMES` [List]

A comma-separated list of alternate DNS names for Puppet Server. For more information go to <https://docs.puppet.com/puppet/latest/reference/configuration.html#dnsaltnames>

```shell
docker run -d -e DNS_ALT_NAMES='puppet,puppet.example.com,puppet.site-a.example.com' vladgh/puppetserver
```

### `JAVA_ARGS` [String]

For more information regarding memory tuning go to <https://docs.puppet.com/puppetserver/2.4/install_from_packages.html#memory-allocation> and <https://docs.puppet.com/puppetserver/2.4/tuning_guide.html>

```shell
docker run -d -e JAVA_ARGS='-Xms512m -Xmx512m' vladgh/puppetserver
```

## Complete run example

```shell
docker run \
  --detach \
  -p 8140:8140 \
  --hostname puppet \
  --name puppet \
  -v $(pwd)/code:/etc/puppetlabs/code \
  -v $(pwd)/ssl:/etc/puppetlabs/puppet/ssl \
  -e PUPPETDB=true \
  -e AUTOSIGN=true \
  -e DNS_ALT_NAMES='puppet,puppet.example.com,puppet.site-a.example.com' \
  -e JAVA_ARGS='-Xms512m -Xmx512m' \
  vladgh/puppetserver
```
