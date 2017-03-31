# S3Sync Docker Image ([Dockerfile](https://github.com/vladgh/docker_base_images/tree/master/s3sync))
[![](https://images.microbadger.com/badges/image/vladgh/s3sync.svg)](https://microbadger.com/images/vladgh/s3sync "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/vladgh/s3sync.svg)](https://microbadger.com/images/vladgh/s3sync "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/vladgh/s3sync.svg)](https://microbadger.com/images/vladgh/s3sync "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/license/vladgh/s3sync.svg)](https://microbadger.com/images/vladgh/s3sync "Get your own license badge on microbadger.com")

This container keeps a local directory synced to an AWS S3 bucket.
It does an initial sync from the specified S3 bucket to a local directory (if it's empty), and then syncs that directory with that S3 bucket. If the local directory was not empty to begin with, it will not do an initial sync.
This is an easy way to back a recent backup copy of data in S3 and have a new node grab it when launched.

_This script is intended for a single node to sync it's files to S3, and SHOULD NOT be used as a permanent backup solution._

The download location inside the container defaults to `/sync` and can be changed via the `SYNCDIR` environment variable.

### Commands
- `download`: (default) downloads the files and exit
- `upload`: uploads the files and exit
- `sync`: uses inotify to upload a directory to S3 when files change (see `SYNCDIR`)
- `cron`: sets-up a cron job to upload files to S3 periodically (see `CRON_TIME`)

### Required environment variables
- `AWS_ACCESS_KEY_ID` (or functional IAM profile)
- `AWS_SECRET_ACCESS_KEY` (or functional IAM profile)
- `AWS_DEFAULT_REGION` (or functional IAM profile)
- `S3PATH`: the S3 synchronize location (ex: `s3://mybucket/myprefix`)

### Optional environment variables
- `SYNCDIR`: the local synchronize location (defaults to `/sync`)
- `CRON_TIME`: a valid cron expression (ex: `CRON_TIME='0 */6 * * *'` runs every 6 hours; defaults to hourly)
- `INITIAL_DOWNLOAD`: whether to download files initially (defaults to `true`)

### Usage:

- Download files and exit
```
docker run \
  -e S3PATH='s3://mybucket/myprefix' \
  vladgh/s3sync
```

- Uplaod files and exit
```
docker run \
  -e S3PATH='s3://mybucket/myprefix' \
  vladgh/s3sync \
  upload
```

- Upload files periodically (every 6 hours)
```
docker run -d \
  -e S3PATH='s3://mybucket/myprefix' \
  -e CRON_TIME='0 */6 * * *' \
  vladgh/s3sync \
  cron
```

- Watch local directory
```
docker run -d \
  -e S3PATH='s3://mybucket/myprefix' \
  vladgh/s3sync \
  sync
```

- Watch the specified local directory (host mount)
```
docker run -d \
  -e S3PATH='s3://mybucket/myprefix' \
  -e SYNCDIR='/mydir' \
  -v $(pwd):/mydir \
  vladgh/s3sync \
  sync
```

- External AWS credentials
```
docker run -d \
  -e S3PATH='s3://textvgh' \
  -v ~/.aws:/root/.aws:ro \
  vladgh/s3sync
```

Thanks to https://github.com/danieldreier/docker-puppet-master-ssl
