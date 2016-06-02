# PuppetServer Docker Image

### Available environment variables:

- `JAVA_ARGS` [String]:
For more information regarding memory tuning go to https://docs.puppet.com/puppetserver/2.4/install_from_packages.html#memory-allocation and https://docs.puppet.com/puppetserver/2.4/tuning_guide.html
```shell
docker run -d -e JAVA_ARGS='-Xms512m -Xmx512m' vladgh/puppetserver
```

- `AUTOSIGN` [Boolean/String]:
Puppet auto signing. For more information regarding policy based auto signing go to https://docs.puppet.com/puppet/latest/reference/ssl_autosign.html#policy-based-autosigning
```shell
docker run -d -e AUTOSIGN='true' vladgh/puppetserver
docker run -d -e AUTOSIGN='false' vladgh/puppetserver
docker run -d -e AUTOSIGN='/usr/local/bin/autosign.sh' vladgh/puppetserver
```

### Complete run example:

```
docker run \
  --detach \
  -p 8140:8140 \
  --hostname puppet \
  -v $(pwd)/code:/etc/puppetlabs/code \
  -v $(pwd)/ssl:/etc/puppetlabs/puppet/ssl \
  -e AUTOSIGN='/usr/local/bin/autosign.sh' \
  -e JAVA_ARGS='-Xms512m -Xmx512m' \
  vladgh/puppetserver
```
