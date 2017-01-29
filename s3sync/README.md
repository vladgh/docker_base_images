# S3Sync Docker Image ([Dockerfile](https://github.com/vladgh/docker_base_images/tree/master/s3sync))
[![](https://images.microbadger.com/badges/image/vladgh/s3sync.svg)](https://microbadger.com/images/vladgh/s3sync "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/vladgh/s3sync.svg)](https://microbadger.com/images/vladgh/s3sync "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/vladgh/s3sync.svg)](https://microbadger.com/images/vladgh/s3sync "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/license/vladgh/s3sync.svg)](https://microbadger.com/images/vladgh/s3sync "Get your own license badge on microbadger.com")

This container synchronizes a local directory with AWS S3.
By default, it downloads the S3 files and stops.

If you pass the `INTERVAL` environment variable, it will run in a loop, at the
specified interval, in seconds (ex: `INTERVAL=600`).

If you pass the `WATCHDIR` environment variable, it will watch for changes in
a directory and synchronize them to S3. This script is intended for a single
machine to sync it's files to S3, and SHOULD NOT be used as a backup solution.

Required variables:
- `S3PATH`: the S3 sync destination (ex: `s3://mybucket/myprefix`)
- `WATCHDIR`: the watched directory (ex: `/watch`)
- `INTERVAL`: the number of seconds between S3 sync runs (ex: `600`)

Optional variables :
- `AWS_ACCESS_KEY_ID` (or functional IAM profile)
- `AWS_SECRET_ACCESS_KEY` (or functional IAM profile)
- `AWS_DEFAULT_REGION` (or functional IAM profile)
- `DESTINATION`: the local destination (defaults to `/sync`)

Run command examples:

- Simple
```
docker run \
  -e S3PATH=s3://mybucket/myprefix \
  vladgh/s3sync
```

- Synchronize at an interval
```
docker run -d \
  -e S3PATH=s3://mybucket/myprefix \
  -e INTERVAL=3600 \
  vladgh/s3sync
```

- Watch local directory
```
docker run -d \
  -e S3PATH=s3://mybucket/myprefix \
  -e WATCHDIR=/watch \
  vladgh/s3sync
```

- External mounted `/watch` directory
```
docker run -d \
  -e S3PATH=s3://mybucket/myprefix \
  -e WATCHDIR=/watch \
  -v $(pwd):/watch \
  vladgh/s3sync
```

Based on https://github.com/danieldreier/docker-puppet-master-ssl
