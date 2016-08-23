# Backup container

Environment variables :
- `AWS_S3_BUCKET`: the name of the bucket (defaults to backups_vgh_{ID})
- `AWS_ACCESS_KEY_ID`: the key id (or functional IAM profile)
- `AWS_SECRET_ACCESS_KEY`: the secret key (or functional IAM profile)
- `AWS_DEFAULT_REGION`: the default region (defaults to 'us-east-1')
- `GPG_RECIPIENT`: the id of the intended recipient
                   if it's missing, the archive will NOT be encrypted
- `BACKUP_PATHS`: a space separated list of paths from inside de container that
                  will be archived (defaults to '/backup')
- `CRON_TIME`: a valid cron expression

## Backup

```
docker run --rm -it \
  -e AWS_ACCESS_KEY_ID=1234 \
  -e AWS_SECRET_ACCESS_KEY=5678 \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -e GPG_RECIPIENT=ADBCDEFGH \
  -e BACKUP_PATHS=/backup1 /backup2 \
  -e CRON_TIME= '0 0 * * *'\
  -v ~/.aws:/root/.aws:ro \
  -v ~/KeysPath:/keys:ro \
  -v ~/path/to/first/backup/dir:/backup1 \
  -v ~/path/to/second/backup/dir:/backup2 \
  vladgh/backup
```

## Cronjob

```
docker run -d \
  -e AWS_ACCESS_KEY_ID=1234 \
  -e AWS_SECRET_ACCESS_KEY=5678 \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -e GPG_RECIPIENT=ADBCDEFGH \
  -e BACKUP_PATHS=/backup1 /backup2 \
  -v ~/.aws:/root/.aws:ro \
  -v ~/KeysPath:/keys:ro \
  -v ~/path/to/first/backup/dir:/backup1 \
  -v ~/path/to/second/backup/dir:/backup2 \
  vladgh/backup cronjob
```
## Restore

Runs one time in interactive mode and it will ask for the GPG key passphrase

```
docker run --rm -it \
  -e AWS_ACCESS_KEY_ID=1234 \
  -e AWS_SECRET_ACCESS_KEY=5678 \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -e BACKUP_RESTORE=true \
  -v ~/.aws:/root/.aws:ro \
  -v ~/KeysPath:/keys:ro \
  -v ~/RestorePath:/restore \
  vladgh/backup restore
```

## Encryption

- Generate GPG key
```
gpg --gen-key
```

- Export public GPG key
```
gpg --output my_key.pub --armor --export me@example.com
```

- Export private GPG key (KEEP SAFE)
```
gpg --output my_rsa_key --armor --export-secret-key me@example.com
```

- Find GPG_RECIPIENT
  It's the 8-digit hexadecimal number on the 'pub' line corresponding to your key.
```
gpg --list-keys
```
