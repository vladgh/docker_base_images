FROM alpine:3.20.0@sha256:77726ef6b57ddf65bb551896826ec38bc3e53f75cdde31354fbffb4f25238ebd
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Environment
ENV AWS_DEFAULT_REGION=us-east-1

# Install packages
RUN apk --no-cache add aws-cli bash findutils groff less tini inotify-tools

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
