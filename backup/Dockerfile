FROM alpine:latest
MAINTAINER Vlad Ghinea vlad@ghn.me

# Install packages
RUN apk --no-cache add bash git gnupg haveged xz python && \
    apk --no-cache add --virtual build-dependencies py-pip && \
    pip install awscli && \
    apk del build-dependencies

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
