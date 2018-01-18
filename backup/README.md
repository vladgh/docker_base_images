# Backup Docker Image ([Dockerfile](https://github.com/vladgh/docker_base_images/tree/master/backup))
[![](https://images.microbadger.com/badges/image/vladgh/backup.svg)](https://microbadger.com/images/vladgh/backup "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/vladgh/backup.svg)](https://microbadger.com/images/vladgh/backup "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/vladgh/backup.svg)](https://microbadger.com/images/vladgh/backup "Get your own commit badge on microbadger.com")
[![](https://images.microbadger.com/badges/license/vladgh/backup.svg)](https://microbadger.com/images/vladgh/backup "Get your own license badge on microbadger.com")

## Environment variables :

- `AWS_S3_BUCKET`: the name of the AWS S3 bucket (defaults to backup_{ID})
- `AWS_S3_PREFIX`: the prefix for the keys inside the AWS S3 bucket (no leading or trailing slashes)
- `GPG_PASSPHRASE`: The GPG passphrase
- `GPG_PASSPHRASE_FILE`: The file containing the GPG passphrase (for example a docker swarm secret mounted at /run/secrets/my_gpg_pass)
- `GPG_RECIPIENT`: the intended recipient or comma separated list of recipients; it can be a key ID, a full fingerprint, an email address, or anything else that uniquely identifies a public key to GPG (see "HOW TO SPECIFY A USER ID" in the gpg man page)
- `GPG_KEY_URL`:  URL or comma separated list of URLs to the public GPG key(s)
- `GPG_KEY_PATH`: container path to the GPG key (can be a file or a folder; if this is a folder, all files will be imported; defaults to '/keys')
- `BACKUP_PATH`: container path to be archived (defaults to '/backup')
- `RESTORE_PATH`: container path to restore (defaults to '/restore')
- `CRON_TIME`: a valid cron expression (it only applies to the "hourly" backups; defaults to every 8 hours, at midnight, Sunday, and the first day of each month; see Rotation below)
- `TIME_ZONE`: timezone in TZ format (defaults to 'UTC')
- `TIME_SERVER`: timeserver (defaults to 'pool.ntp.org')

## AWS credentials

You can declare AWS credentials in several ways:

1. As environment variables

```
docker run ...
-e AWS_ACCESS_KEY_ID=1234 \
-e AWS_SECRET_ACCESS_KEY=5678 \
-e AWS_DEFAULT_REGION=us-east-1 \
...
```

2. Mount the configuration directory

```
docker run ...
-v ~/.aws:/root/.aws:ro
...
```

3. If you are using Docker Swarm Secrets, you can create a secret with a target to `/root/.aws/credentials`.

```
docker service create ...
--secret source=aws_credentials,target=/root/.aws/credentials,mode=0400
...
```

For more information on Docker Swarm secrets, read: https://docs.docker.com/engine/swarm/secrets/. For information about a AWS CLI credentials file, read: http://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html

## GPG keys

You can import the GPG keys in several ways:

1. From an URL

```
docker run ...
-e GPG_KEY_URL='https://keybase.io/example/key.asc' \
...
```

2. From a file (which needs to be mounted from the host)

```
docker run ...
-v /host/path/to/GPG/key:/key:ro \
-e GPG_KEY_PATH='/key' \
...
```

2. From a folder (which needs to be mounted from the host)

```
docker run ...
-v /host/path/to/GPG/keys:/keys:ro \
-e GPG_KEY_PATH='/keys' \
...
```

## One time backup

```
docker run --rm -it \
  -e AWS_S3_BUCKET=mybucket \
  -e GPG_RECIPIENT=me@example.com \
  -e GPG_KEY_URL='https://keybase.io/example/key.asc' \
  -v ~/.aws:/root/.aws:ro \
  -v /etc/localtime:/etc/localtime:ro \
  -v /path/to/backup/dir1:/backup/dir1:ro \
  -v /path/to/backup/dir2:/backup/dir2:ro \
  vladgh/backup
```

## One time backup (symmetric encryption with passphrase)

```
docker run --rm -it \
  -e AWS_S3_BUCKET=mybucket \
  -e GPG_PASSPHRASE='mysuperstrongpassword' \
  -v ~/.aws:/root/.aws:ro \
  -v /etc/localtime:/etc/localtime:ro \
  -v /path/to/backup/dir1:/backup/dir1:ro \
  -v /path/to/backup/dir2:/backup/dir2:ro \
  vladgh/backup
```

## Cronjob

```
docker run -d \
  -e AWS_S3_BUCKET=mybucket \
  -e GPG_RECIPIENT=me@example.com \
  -e CRON_TIME= '0 */2 * * *'\
  -v ~/.aws:/root/.aws:ro \
  -v /etc/localtime:/etc/localtime:ro \
  -v /host/path/to/GPG/keys:/keys:ro \
  -v /path/to/backup/dir1:/backup/dir1:ro \
  -v /path/to/backup/dir2:/backup/dir2:ro \
  vladgh/backup cron
```

## Restore
If the right AWS credentials are specified, it will try to download the latest object from the specified bucket (with the specified prefix).
The private GPG key needs to be imported (see [GPG keys](#gpg-keys)), and the passphrase needs to be declared (via `GPG_PASSPHRASE` or `GPG_PASSPHRASE_FILE`)

```
docker run --rm -it \
  -e AWS_S3_BUCKET=mybucket \
  -e GPG_PASSPHRASE=myverystrongpassword \
  -v ~/.aws:/root/.aws:ro \
  -v /host/path/to/GPG/private/key:/keys/my_private_key:ro \
  -v /host/path/to/restore:/restore \
  vladgh/backup restore
```

## Restore single file
You can also restore a single encrypted file by piping it into the container (**Note: do not allocate a TTY to this container**)

```
docker run --rm -i \
  -e GPG_PASSPHRASE=myverystrongpassword \
  -v /host/path/to/GPG/private/key:/keys/my_private_key:ro \
  -v /host/path/to/restore:/restore \
  vladgh/backup restore < /path/to/host/restore_file.tar.xz.gpg
```

## Restore single file (with symmetric encryption)
**Note: do not allocate a TTY to this container**

```
docker run --rm -i \
  -e GPG_PASSPHRASE=myverystrongpassword \
  -v /host/path/to/restore:/restore \
  vladgh/backup restore < /path/to/host/restore_file.tar.xz.gpg
```
## Restore single file (mounted inside the container)

```
docker run --rm -it \
  -e GPG_PASSPHRASE=myverystrongpassword \
  -v /host/path/to/restore:/restore \
  -v /host/path/to/restore_file.tar.xz:/container/path/to/restore_file.tar.xz.gpg \
  vladgh/backup restore /container/path/to/restore_file.tar.xz.gpg
```

## Restore single file (without encryption)

```
docker run --rm -it \
  -v /host/path/to/restore:/restore \
  -v /host/path/to/restore_file.tar.xz:/container/path/to/restore_file.tar.xz \
  vladgh/backup restore /container/path/to/restore_file.tar.xz
```

## Encryption

```
# Start container
docker run --rm -it -v /path/to/keys/store:/keys -e GPG_TTY=/dev/console --entrypoint bash vladgh/backup

# Generate GPG key
gpg --full-gen-key

# If the command complaints about more entropy start the following container in a new session on the same host
docker run --rm --privileged --entrypoint haveged vladgh/backup -F

# Export public GPG key
gpg --output /keys/my_key.pub --armor --export me@example.com

# Export private GPG key (KEEP SAFE)
gpg --output /keys/my_rsa_key --armor --export-secret-key me@example.com

# Find GPG_RECIPIENT; It's the 8-digit hexadecimal number on the 'pub' line corresponding to your key.
gpg --list-keys
```

## Rotation

The recommended rotation method is by using life cycle rules for the S3 bucket. A json file is included as example. It will remove backups according to the following schedule:
- hourly backups expire after 1 day
- daily backups expire after 7 days
- monthly backups expire after 30 days

```
aws s3api put-bucket-lifecycle --bucket mybucket --lifecycle-configuration file://lifecycle.json
```
