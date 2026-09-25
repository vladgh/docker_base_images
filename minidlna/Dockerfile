FROM alpine:3@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

ARG MINIDLNA_VERSION=1.3.3-r3

# Install
RUN apk --no-cache add bash curl minidlna=${MINIDLNA_VERSION} minidlna-lang=${MINIDLNA_VERSION} \
  tini shadow su-exec alpine-conf inotify-tools

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

# Health check
HEALTHCHECK --interval=10s --timeout=10s --retries=6 CMD \
  curl --silent --fail 127.0.0.1:"${MINIDLNA_PORT:-8200}" || exit 1
