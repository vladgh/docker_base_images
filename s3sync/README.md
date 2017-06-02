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

## AWS credentials

You can declare AWS credentials in 3 ways:

1. As environment variables
```SH
docker run ...
-e AWS_ACCESS_KEY_ID=1234 \
-e AWS_SECRET_ACCESS_KEY=5678 \
-e AWS_DEFAULT_REGION=us-east-1 \
...
```

2. Mount the configuration directory
```SH
docker run ...
-v ~/.aws:/root/.aws:ro
...
```

3. If you are using Docker Swarm secrets, the credentials for AWS are automatically loaded from an `aws_credentials` secret (if it exists). This will link to `~/.aws/credentials`. For more information on Docker Swarm secrets, read: https://docs.docker.com/engine/swarm/secrets/. For information about a AWS CLI credentials file, read: http://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html

### Commands
- `download`: (default) downloads the files and exits
- `upload`: uploads the files and exits
- `sync`: uses inotify to upload a directory to S3 when files change (see `SYNCDIR`)
- `periodic_upload`: sets up a cron job to upload files to S3 periodically (see `CRON_TIME` and `INITIAL_DOWNLOAD`)
- `periodic_download`: sets up a cron job to download files from S3 periodically (see `CRON_TIME` and `INITIAL_DOWNLOAD`)

### Required environment variables
- `AWS_ACCESS_KEY_ID` (or functional IAM profile)
- `AWS_SECRET_ACCESS_KEY` (or functional IAM profile)
- `AWS_DEFAULT_REGION` (or functional IAM profile)
- `S3PATH`: the S3 synchronize location (ex: `s3://mybucket/myprefix`)

### Optional environment variables
- `SYNCDIR`: the local synchronize location (defaults to `/sync`)
- `CRON_TIME`: a valid cron expression (ex: `CRON_TIME='0 */6 * * *'` runs every 6 hours; defaults to hourly)
- `INITIAL_DOWNLOAD`: whether to download files initially (defaults to `true`); this will only download the files if the directory is empty. Set this to `force` to skip this check

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
