# PuppetServer Docker Image

### Available environment variables:

- `JAVA_ARGS`:
For more information regarding memory tuning go to https://docs.puppet.com/puppetserver/2.4/install_from_packages.html#memory-allocation and https://docs.puppet.com/puppetserver/2.4/tuning_guide.html

```shell
docker run -d -e JAVA_ARGS='-Xms512m -Xmx512m' vladgh/puppetserver
```

### Run example:
```
docker run -d --hostname puppet -v $(pwd)/code:/etc/puppetlabs/code -p 8140:8140 vladgh/puppetserver
```
