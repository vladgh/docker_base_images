FROM alpine:3.20.3@sha256:a8f120106f5549715aa966fd7cefaf3b7045f6414fed428684de62fec8c2ca4b
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Environment
ENV AWS_DEFAULT_REGION=us-east-1

# Install packages
RUN apk --no-cache add aws-cli bash findutils groff less tini inotify-tools

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
