FROM alpine:3.9
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Environment
ENV SERVER_PORT=10514

# Install packages
RUN apk --no-cache add bash rsyslog rsyslog-tls tini tzdata

# Ports
EXPOSE "$SERVER_PORT"

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.opencontainers.image.title="VGH RSYSLOG" \
      org.opencontainers.image.url="$VCS_URL" \
      org.opencontainers.image.authors="Vlad Ghinea" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.version="$VERSION" \
      org.opencontainers.image.source="$VCS_URL" \
      org.opencontainers.image.revision="$VCS_REF" \
      org.opencontainers.image.created="$BUILD_DATE"
