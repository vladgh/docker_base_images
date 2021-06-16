# R10K Docker Image ([Dockerfile](Dockerfile))
[![](https://images.microbadger.com/badges/image/vladgh/r10k.svg)](https://microbadger.com/images/vladgh/r10k "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/vladgh/r10k.svg)](https://microbadger.com/images/vladgh/r10k "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/vladgh/r10k.svg)](https://microbadger.com/images/vladgh/r10k "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/license/vladgh/r10k.svg)](https://microbadger.com/images/vladgh/r10k "Get your own version badge on microbadger.com")

## **⚠️ This project is no longer supported!**

## Source
https://github.com/puppetlabs/r10k

## Environment variables :
- `REMOTE`: the URL of the remote Puppet control repository (required unless the configuration file is already mounted)
- `POSTRUN`: specifies an arbitrary command to run after deploying all environments. The command must be an array of strings that will be used as an argument vector. (ex: POSTRUN="['/usr/bin/curl', '-F', 'deploy=done', 'http://my-app.site/endpoint']")
- `CRONTIME`: a valid cron expression to run R10K deployment (ex: CRONTIME='0 */6 * * *' runs every 6 hours)
- `CACHEDIR`: the location to use for storing cached Git repos (defaults to `/var/cache/r10k`)

## Run example
This image supports any R10K command passed directly to the container.
```
docker run -it \
  -v $(pwd)/Puppetfile:/Puppetfile \
  vladgh/r10k \
  r10k puppetfile check
```
```
docker run -it \
  -v $(pwd)/Puppetfile:/Puppetfile \
  vladgh/r10k \
  r10k puppetfile install --verbose
```
```
docker run -it \
  -v $(pwd)/Puppetfile:/Puppetfile \
  -v $(pwd)/cache:/var/cache/r10k \
  vladgh/r10k \
  r10k puppetfile install --verbose
```

If there is a `CRONTIME` environment variable, the container will run the command once and then setup a cron job to rerun it periodically.
```
docker run -it \
  -e REMOTE='https://github.com/me/example.git' \
  -e CRONTIME='0 */6 * * *'
  vladgh/r10k \
  r10k deploy environment --puppetfile --verbose
```

If there is a `POSTRUN` environment variable, the container will run the specified command after deploying all environments.
```
docker run -it \
  -e REMOTE='https://github.com/me/example.git' \
  -e POSTRUN="['/usr/bin/curl', '-F', 'deploy=done', 'http://my-app.site/endpoint']"
  vladgh/r10k \
  r10k deploy environment --puppetfile --verbose
```

You can also provide the R10K configuration file as a mount point or mount the cache directory
```
docker run -it \
  -v $(pwd)/r10k.yaml:/etc/puppetlabs/r10k/r10k.yaml \
  -v $(pwd)/cache:/var/cache/r10k \
  vladgh/r10k \
  r10k deploy environment --puppetfile --verbose
```
