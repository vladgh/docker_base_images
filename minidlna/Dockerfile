FROM alpine:20250108@sha256:115729ec5cb049ba6359c3ab005ac742012d92bbaa5b8bc1a878f1e8f62c0cb8
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
