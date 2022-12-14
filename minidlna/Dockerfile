FROM alpine:20221110
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Install
RUN apk --no-cache add bash curl minidlna tini shadow su-exec alpine-conf inotify-tools

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

# Health check
HEALTHCHECK --interval=10s --timeout=10s --retries=6 CMD \
  curl --silent --fail 127.0.0.1:8200 || exit 1
