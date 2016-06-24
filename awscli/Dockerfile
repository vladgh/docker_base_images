FROM alpine:latest
MAINTAINER Vlad Ghinea vlad@ghn.me

# Environment
ENV AWS_DEFAULT_REGION=us-east-1

# Install packages
RUN apk --no-cache add bash python git && \
    apk --no-cache add --virtual build-dependencies py-pip && \
    pip install awscli && \
    apk del build-dependencies

# Default command
CMD ["/bin/bash"]
