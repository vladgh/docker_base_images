FROM alpine:3.23.3@sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Environment
ENV AWS_DEFAULT_REGION=us-east-1

# Install packages
RUN apk --no-cache add aws-cli bash findutils groff less tini inotify-tools

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
