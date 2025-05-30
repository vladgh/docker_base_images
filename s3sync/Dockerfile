FROM alpine:3.22.0@sha256:8a1f59ffb675680d47db6337b49d22281a139e9d709335b492be023728e11715
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Environment
ENV AWS_DEFAULT_REGION=us-east-1

# Install packages
RUN apk --no-cache add aws-cli bash findutils groff less tini inotify-tools

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
