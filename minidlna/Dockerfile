FROM alpine:20240807@sha256:b93f4f6834d5c6849d859a4c07cc88f5a7d8ce5fb8d2e72940d8edd8be343c04
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

ARG MINIDLNA_VERSION=1.3.3-r0

# Install
RUN apk --no-cache add bash curl minidlna=${MINIDLNA_VERSION} tini shadow su-exec alpine-conf inotify-tools

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

# Health check
HEALTHCHECK --interval=10s --timeout=10s --retries=6 CMD \
  curl --silent --fail 127.0.0.1:"${MINIDLNA_PORT:-8200}" || exit 1
