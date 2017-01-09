# R10K Docker Image ([Dockerfile](https://github.com/vladgh/docker_base_images/tree/master/r10k))
[![](https://images.microbadger.com/badges/image/vladgh/r10k.svg)](https://microbadger.com/images/vladgh/r10k "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/vladgh/r10k.svg)](https://microbadger.com/images/vladgh/r10k "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/vladgh/r10k.svg)](https://microbadger.com/images/vladgh/r10k "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/license/vladgh/r10k.svg)](https://microbadger.com/images/vladgh/r10k "Get your own version badge on microbadger.com")

## Source

https://github.com/puppetlabs/r10k

## Run example

- Provide the R10K configuration file as a mount point
```
docker run -it \
  -v $(pwd)/r10k.yaml:/etc/puppetlabs/r10k/r10k.yaml \
  vladgh/r10k \
  r10k deploy environment --puppetfile --verbose
```

- Provide the URL of the remote Puppet control repository
```
docker run -it \
  -e REMOTE='https://github.com/me/example.git' \
  vladgh/r10k \
  r10k deploy environment --puppetfile --verbose
```
