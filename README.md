# Vlad's Docker Base Images

## Description
You can find published versions of these images on [Docker Hub](https://hub.docker.com/r/vladgh):
* [vladgh/apache](https://hub.docker.com/r/vladgh/apache)
* [vladgh/awscli](https://hub.docker.com/r/vladgh/awscli)
* [vladgh/backup](https://hub.docker.com/r/vladgh/backup)
* [vladgh/deluge](https://hub.docker.com/r/vladgh/deluge)
* [vladgh/fpm](https://hub.docker.com/r/vladgh/fpm)
* [vladgh/minidlna](https://hub.docker.com/r/vladgh/minidlna)
* [vladgh/puppet](https://hub.docker.com/r/vladgh/puppet)
* [vladgh/puppetserver](https://hub.docker.com/r/vladgh/puppetserver)
* [vladgh/r10k](https://hub.docker.com/r/vladgh/r10k)
* [vladgh/s3sync](https://hub.docker.com/r/vladgh/s3sync)

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
Bug reports and pull requests are welcome. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.
1. Open an issue to discuss proposed changes
2. Fork the repository
3. Create your feature branch: `git checkout -b my-new-feature`
4. Commit your changes: `git commit -am 'Add some feature'`
5. Push to the branch: `git push origin my-new-feature`
6. Submit a pull request :D

## License
Licensed under the Apache License, Version 2.0.
