# Backup Docker Image ([Dockerfile](https://github.com/vladgh/docker_base_images/tree/master/backup))
[![](https://images.microbadger.com/badges/image/vladgh/backup.svg)](https://microbadger.com/images/vladgh/backup "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/vladgh/backup.svg)](https://microbadger.com/images/vladgh/backup "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/vladgh/backup.svg)](https://microbadger.com/images/vladgh/backup "Get your own commit badge on microbadger.com")
[![](https://images.microbadger.com/badges/license/vladgh/backup.svg)](https://microbadger.com/images/vladgh/backup "Get your own license badge on microbadger.com")

## Environment variables :

- `AWS_ACCESS_KEY_ID`: the key id (or functional IAM profile)
- `AWS_SECRET_ACCESS_KEY`: the secret key (or functional IAM profile)
- `AWS_DEFAULT_REGION`: the default region (defaults to 'us-east-1')
- `AWS_S3_BUCKET`: the name of the bucket (defaults to backups_{ID})
- `GPG_RECIPIENT`: the id of the intended recipient; if it's missing, the archive will NOT be encrypted
- `BACKUP_PATHS`: a space separated list of paths from inside de container that will be archived (defaults to '/backup')
- `CRON_TIME`: a valid cron expression (it only applies to the "hourly" backups; defaults to every 8 hours, at midnight, Sunday, and the first day of each month; see Rotation below)

## One time backup

```SH
docker run --rm -it \
  -e AWS_ACCESS_KEY_ID=1234 \
  -e AWS_SECRET_ACCESS_KEY=5678 \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -e AWS_S3_BUCKET=mybucket \
  -e GPG_RECIPIENT=ADBCDEFGH \
  -e BACKUP_PATHS=/backup1 /backup2 \
  -v ~/.aws:/root/.aws:ro \
  -v /etc/localtime:/etc/localtime:ro
  -v ~/KeysPath:/keys:ro \
  -v ~/path/to/first/backup/dir:/backup1 \
  -v ~/path/to/second/backup/dir:/backup2 \
  vladgh/backup
```

## Cronjob

```SH
docker run -d \
  -e AWS_ACCESS_KEY_ID=1234 \
  -e AWS_SECRET_ACCESS_KEY=5678 \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -e AWS_S3_BUCKET=mybucket \
  -e GPG_RECIPIENT=ADBCDEFGH \
  -e BACKUP_PATHS=/backup1 /backup2 \
  -e CRON_TIME= '0 */2 * * *'\
  -v ~/.aws:/root/.aws:ro \
  -v /etc/localtime:/etc/localtime:ro
  -v ~/KeysPath:/keys:ro \
  -v ~/path/to/first/backup/dir:/backup1 \
  -v ~/path/to/second/backup/dir:/backup2 \
  vladgh/backup cron
```

## Restore

```SH
docker run --rm -it \
  -e AWS_ACCESS_KEY_ID=1234 \
  -e AWS_SECRET_ACCESS_KEY=5678 \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -e AWS_S3_BUCKET=mybucket \
  -e BACKUP_RESTORE=true \
  -v ~/.aws:/root/.aws:ro \
  -v ~/KeysPath:/keys:ro \
  -v ~/RestorePath:/restore \
  vladgh/backup restore
```

Notes:
* Runs one time in interactive mode and it will ask for the GPG key passphrase.
* The private GPG key needs to be imported from the `/keys` folder.

## Encryption

```SH
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

The recommended rotation method is by using lifecycle rules for the S3 bucket. A json file is included as example. It will remove backups according to the following schedule:
- hourly backups expire after 1 day
- daily backups expire after 7 days
- monthly backups expire after 30 days

```SH
aws s3api put-bucket-lifecycle --bucket mybucket --lifecycle-configuration file://lifecycle.json
```
