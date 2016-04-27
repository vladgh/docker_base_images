# PuppetServer Docker Image

### Available environment variables:
- `JAVA_ARGS`:
```shell
docker run -d -e JAVA_ARGS='-Xms256m -Xmx512m' vladgh/puppetserver
```

### Run example:
```
docker run -d --hostname puppet -v $(pwd)/code:/etc/puppetlabs/code -p 8140:8140 vladgh/puppetserver
```
