# AWS Command Line Interface Docker Image ([Dockerfile](https://github.com/vladgh/docker_base_images/tree/master/awscli))

Docker image with the AWS Command Line Interface installed.

Optional variables :
- `AWS_ACCESS_KEY_ID` (or functional IAM profile)
- `AWS_SECRET_ACCESS_KEY` (or functional IAM profile)
- `AWS_DEFAULT_REGION` (defaults to 'us-east-1')

## Run command examples:

- Simple
```
docker run -it \
  -e AWS_ACCESS_KEY_ID=1234 \
  -e AWS_SECRET_ACCESS_KEY=5678 \
  vladgh/awscli
```

- Provide the .aws config folder
```
docker run -it \
  -v ~/.aws:/root/.aws \
  vladgh/awscli
```

- Describe an EC2 instance
```
docker run \
  -e AWS_ACCESS_KEY_ID=1234 \
  -e AWS_SECRET_ACCESS_KEY=5678 \
  -e AWS_DEFAULT_REGION=us-west-2 \
  vladgh/awscli \
  aws ec2 describe-instances --instance-ids i-1234
```

## AWS Command Line Reference
http://docs.aws.amazon.com/cli/latest/reference/
