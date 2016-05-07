# S3 Sync

Watches for changes in a directory and syncs them to S3.

Optional variables :
- `AWS_ACCESS_KEY_ID` (or functional IAM profile)
- `AWS_SECRET_ACCESS_KEY` (or functional IAM profile)
- `AWS_DEFAULT_REGION` (or functional IAM profile)
- `EVENTS`: the inotify events to watch for. Defaults to:
            'CREATE,DELETE,MODIFY,MOVE,MOVED_FROM,MOVED_TO'
- `WATCHDIR`: the watched directory. Defaults to: `/watch`

Run command examples:

- Simple
```
docker run -d vladgh/s3sync s3://mybucket/mykeyprefix
```

- External mounted `/watch` directory
```
docker run -d \
  -v $(pwd):/watch \
  vladgh/s3sync s3://mybucket/mykeyprefix
```

- Change the default directory
```
docker run -d \
  -e WATCHDIR=/mywatchdir \
  vladgh/s3sync s3://mybucket/mykeyprefix
```

- Provide the .aws config folder
```
docker run -d \
  -v ~/.aws:/root/.aws \
  vladgh/s3sync s3://mybucket/mykeyprefix
```

Based on https://github.com/danieldreier/docker-puppet-master-ssl
