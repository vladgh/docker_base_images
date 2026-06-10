FROM alpine:3.24.0@sha256:8ddefa941e689fc29abcdeb8dae3b3c6d139cc08ce9a52633931160701770685
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Environment
ENV AWS_DEFAULT_REGION=us-east-1

# Install packages
RUN apk --no-cache add aws-cli bash findutils groff less tini inotify-tools

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
