# S3Sync Docker Image ([Dockerfile](https://github.com/vladgh/docker_base_images/tree/master/s3sync))
[![](https://images.microbadger.com/badges/image/vladgh/s3sync.svg)](https://microbadger.com/images/vladgh/s3sync "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/vladgh/s3sync.svg)](https://microbadger.com/images/vladgh/s3sync "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/vladgh/s3sync.svg)](https://microbadger.com/images/vladgh/s3sync "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/license/vladgh/s3sync.svg)](https://microbadger.com/images/vladgh/s3sync "Get your own license badge on microbadger.com")

This container synchronizes a local directory with AWS S3.
By default, it downloads the S3 files and stops.

If you pass the `WATCHDIR` environment variable, it will watch for changes in
a directory and synchronize them to S3. This script is intended for a single
machine to sync it's files to S3, and SHOULD NOT be used as a backup solution.

If you pass the `CRON_TIME` environment variable, it will run once and then setup a cron job to rerun it periodically (ex: CRON_TIME='0 */6 * * *' runs every 6 hours).

Environment variables:
- `AWS_ACCESS_KEY_ID` (or functional IAM profile)
- `AWS_SECRET_ACCESS_KEY` (or functional IAM profile)
- `AWS_DEFAULT_REGION` (or functional IAM profile)
- `S3PATH`: the S3 sync destination (ex: `s3://mybucket/myprefix`)
- `DESTINATION`: the local destination (defaults to `/sync`)
- `WATCHDIR`: the watched directory (ex: `/watch`)
- `CRON_TIME`: a valid cron expression (ex: CRON_TIME='0 */6 * * *' runs every 6 hours)

Run command examples:

- Simple
```
docker run \
  -e S3PATH='s3://mybucket/myprefix' \
  vladgh/s3sync
```

- Synchronize periodically
```
docker run -d \
  -e S3PATH='s3://mybucket/myprefix' \
  -e CRON_TIME='0 */6 * * *' \
  vladgh/s3sync
```

- Watch local directory
```
docker run -d \
  -e S3PATH='s3://mybucket/myprefix' \
  -e WATCHDIR='/watch' \
  vladgh/s3sync
```

- External AWS credentials
```
docker run -d \
  -e S3PATH='s3://mybucket/myprefix' \
  -v ~/.aws:/root/.aws:ro \
  vladgh/s3sync
```

- External mounted `/watch` directory
```
docker run -d \
  -e S3PATH='s3://mybucket/myprefix' \
  -e WATCHDIR='/watch' \
  -v $(pwd):/watch \
  vladgh/s3sync
```

Based on https://github.com/danieldreier/docker-puppet-master-ssl
