FROM alpine:20240329@sha256:e31c3b1cd47718260e1b6163af0a05b3c428dc01fa410baf72ca8b8076e22e72
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

ARG MINIDLNA_VERSION=1.3.3-r1

# Install
RUN apk --no-cache add bash curl minidlna=${MINIDLNA_VERSION} tini shadow su-exec alpine-conf inotify-tools

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

# Health check
HEALTHCHECK --interval=10s --timeout=10s --retries=6 CMD \
  curl --silent --fail 127.0.0.1:"${MINIDLNA_PORT:-8200}" || exit 1
