# S3 Sync

Watch for changes in a directory and sync them to S3.

Requirements:
- The watched directory on the host needs to be mounted to the /watch container
directory
- The `S3PATH` environment variables must be set with an existing S3 path

Optional variables :
- AWS_ACCESS_KEY_ID (or functional IAM profile)
- AWS_SECRET_ACCESS_KEY (or functional IAM profile)
- AWS_DEFAULT_REGION (or functional IAM profile)

Run command:
docker run -d -v $(pwd):/watch -e S3PATH=s3://mybucket/mykeyprefix vladgh/s3sync

Based on https://github.com/danieldreier/docker-puppet-master-ssl
