# S3Sync Docker Image ([Dockerfile](Dockerfile))

This container keeps a local directory synced to an AWS S3 bucket.
It does an initial sync from the specified S3 bucket to a local directory (if it's empty), and then syncs that directory with that S3 bucket. If the local directory was not empty to begin with, it will not do an initial sync.
This is an easy way to back a recent backup copy of data in S3 and have a new node grab it when launched.

_This script is intended for a single node to sync it's files to S3, and SHOULD NOT be used as a permanent backup solution._

The download location inside the container defaults to `/sync` and can be changed via the `SYNCDIR` environment variable.

## AWS credentials

You can declare AWS credentials in 3 ways:

- As environment variables

```SH
docker run ...
-e AWS_ACCESS_KEY_ID=1234 \
-e AWS_SECRET_ACCESS_KEY=5678 \
-e AWS_DEFAULT_REGION=us-east-1 \
...
```

- Mount the configuration directory

```SH
docker run ...
-v ~/.aws:/root/.aws:ro
...
```

- If you are using Docker Swarm secrets, the credentials for AWS are automatically loaded from an `aws_credentials` secret (if it exists). This will link to `~/.aws/credentials`. For more information on Docker Swarm secrets, read: <https://docs.docker.com/engine/swarm/secrets/>. For information about a AWS CLI credentials file, read: <http://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html>

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
- `AWS_S3_SSE`: use S3 Server Side Encryption; it can be `false` for no encryption, `aes256` or `true` for Server-Side Encryption with Amazon S3-Managed Keys (SSE-S3) and `kms` for Server-Side Encryption with AWS KMS-Managed Keys (SSE-KMS) (defaults to `false`). For more information refer to <https://docs.aws.amazon.com/AmazonS3/latest/dev/serv-side-encryption.html> (Note: Server-Side Encryption with Customer-Provided Keys (SSE-C) is not currently supported)
- `AWS_S3_SSE_KMS_KEY_ID`: The AWS KMS key ID that should be used to server-side encrypt the object in S3 (only available if use in conjunction with `AWS_S3_SSE`)
- `CRON_TIME`: a valid cron expression (ex: `CRON_TIME='0 */6 * * *'` runs every 6 hours; defaults to hourly)
- `INITIAL_DOWNLOAD`: whether to download files initially (defaults to `true`); this will only download the files if the directory is empty. Set this to `force` to skip this check
- `SYNCEXTRA`: add extra options to aws-cli sync command
- `EXCLUDE` : A RegEx with the following rules to exclude a set of files/directories from being watched and synced. 
    - *: Matches everything
    - ?: Matches any single character
    - [sequence]: Matches any character in sequence
    - [!sequence]: Matches any character not in sequence

### Usage

- Download files and exit

```sh
docker run \
  -e S3PATH='s3://mybucket/myprefix' \
  vladgh/s3sync
```

- Upload files and exit

```sh
docker run \
  -e S3PATH='s3://mybucket/myprefix' \
  vladgh/s3sync \
  upload
```

- Upload files periodically (every 6 hours)

```sh
docker run -d \
  -e S3PATH='s3://mybucket/myprefix' \
  -e CRON_TIME='0 */6 * * *' \
  vladgh/s3sync \
  cron
```

- Watch local directory

```sh
docker run -d \
  -e S3PATH='s3://mybucket/myprefix' \
  vladgh/s3sync \
  sync
```

- Watch local directory excluding log files

```sh
docker run -d \
  -e S3PATH='s3://mybucket/myprefix' \
  -e EXCLUDE='*.log'
  vladgh/s3sync \
  sync
```

- Watch the specified local directory (host mount)

```sh
docker run -d \
  -e S3PATH='s3://mybucket/myprefix' \
  -e SYNCDIR='/mydir' \
  -v $(pwd):/mydir \
  vladgh/s3sync \
  sync
```

- External AWS credentials

```sh
docker run -d \
  -e S3PATH='s3://mybucket/myprefix' \
  -v ~/.aws:/root/.aws:ro \
  vladgh/s3sync
```

Thanks to <https://github.com/danieldreier/docker-puppet-master-ssl>
