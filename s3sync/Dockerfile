FROM alpine:latest
MAINTAINER Vlad Ghinea vlad@ghn.me

# Install iNotify tools
RUN apk --update upgrade && \
    apk add --update bash inotify-tools python py-pip && \
    pip install awscli && \
    apk --purge -v del py-pip && \
    rm -rf /var/cache/apk/*

# Configure entrypoint
COPY /entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
