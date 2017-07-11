# Vlad's Docker Base Images

## Description
You can find published versions of these images on [Docker Hub](https://hub.docker.com/r/vladgh):
* [vladgh/apache](https://hub.docker.com/r/vladgh/apache)
* [vladgh/awscli](https://hub.docker.com/r/vladgh/awscli)
* [vladgh/backup](https://hub.docker.com/r/vladgh/backup)
* [vladgh/deluge](https://hub.docker.com/r/vladgh/deluge)
* [vladgh/fpm](https://hub.docker.com/r/vladgh/fpm)
* [vladgh/gpg](https://hub.docker.com/r/vladgh/gpg)
* [vladgh/minidlna](https://hub.docker.com/r/vladgh/minidlna)
* [vladgh/puppet](https://hub.docker.com/r/vladgh/puppet)
* [vladgh/puppetboard](https://hub.docker.com/r/vladgh/puppetboard)
* [vladgh/puppetdb](https://hub.docker.com/r/vladgh/puppetdb)
* [vladgh/puppetserver](https://hub.docker.com/r/vladgh/puppetserver)
* [vladgh/puppetserverdb](https://hub.docker.com/r/vladgh/puppetserverdb)
* [vladgh/r10k](https://hub.docker.com/r/vladgh/r10k)
* [vladgh/s3sync](https://hub.docker.com/r/vladgh/s3sync)
* [vladgh/webhook](https://hub.docker.com/r/vladgh/webhook)

## Development
### List images
```
bundle exec rake docker:list
```

### Lint images
```
bundle exec rake docker:lint
bundle exec rake docker:{IMAGE}:lint
```

### Test images
```
bundle exec rake docker:spec
bundle exec rake docker:{IMAGE}:spec
```

### Build images
```
bundle exec rake docker:build
bundle exec rake docker:{IMAGE}:build
```

### Push images
```
bundle exec rake docker:push
bundle exec rake docker:{IMAGE}:push
```

## Contribute
See [CONTRIBUTING.md](CONTRIBUTING.md) file.

## License
Licensed under the Apache License, Version 2.0.
See [LICENSE](LICENSE) file.
