# S3Sync Docker Image ([Dockerfile](https://github.com/vladgh/docker_base_images/tree/master/s3sync))
[![](https://images.microbadger.com/badges/image/vladgh/s3sync.svg)](https://microbadger.com/images/vladgh/s3sync "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/vladgh/s3sync.svg)](https://microbadger.com/images/vladgh/s3sync "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/vladgh/s3sync.svg)](https://microbadger.com/images/vladgh/s3sync "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/license/vladgh/s3sync.svg)](https://microbadger.com/images/vladgh/s3sync "Get your own license badge on microbadger.com")

Watches for changes in a directory and syncs them to S3.
The container downloads first the S3 files (overwriting the local ones), and
then runs `aws s3 sync --delete` at the specified interval or when files are
changed. This script is intended for a single machine to sync it's files to S3,
and SHOULD NOT be used as a backup solution.

Optional variables :
- `AWS_ACCESS_KEY_ID` (or functional IAM profile)
- `AWS_SECRET_ACCESS_KEY` (or functional IAM profile)
- `AWS_DEFAULT_REGION` (or functional IAM profile)
- `S3PATH`: the S3 sync destination (reqired; ex: `s3://mybucket/myprefix`)
- `WATCHDIR`: the watched directory (defaults: `/watch`)
- `INTERVAL`: the number of seconds between S3 sync runs (default: `600`)
- `EVENTS`: the inotify events to watch for. Defaults to:
            'CREATE,DELETE,MODIFY,MOVE,MOVED_FROM,MOVED_TO'

Run command examples:

- Simple
```
docker run -d -e S3PATH=s3://mybucket/myprefix vladgh/s3sync
```

- External mounted `/watch` directory
```
docker run -d \
  -e S3PATH=s3://mybucket/myprefix \
  -v $(pwd):/watch \
  vladgh/s3sync
```

- Change the default directory
```
docker run -d \
  -e S3PATH=s3://mybucket/myprefix \
  -e WATCHDIR=/mywatchdir \
  vladgh/s3sync
```

- Change the default interval
```
docker run -d \
  -e S3PATH=s3://mybucket/myprefix \
  -e INTERVAL=3600 \
  vladgh/s3sync
```

- Provide the .aws config folder
```
docker run -d \
  -e S3PATH=s3://mybucket/myprefix \
  -v ~/.aws:/root/.aws \
  vladgh/s3sync
```

Based on https://github.com/danieldreier/docker-puppet-master-ssl
