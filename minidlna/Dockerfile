FROM alpine:3
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

ARG USERNAME=minidlna
ARG GROUPNAME=minidlna
ARG USER_UID=1000
ARG USER_GID="$USER_UID"

# Create the user (before installing the package in order to preserver UID and GID)
RUN addgroup --gid "$USER_GID" "$GROUPNAME" && \
    adduser --disabled-password --ingroup "$GROUPNAME" --uid "$USER_UID" "$USERNAME"

# Install packages
RUN apk --no-cache add bash curl minidlna tini

# We set the read/write permissions to everyone to give the user the possibility to run the container as any desired user
RUN mkdir -p /minidlna/cache && \
    chown -R "${USERNAME}:${GROUPNAME}" /etc/minidlna.conf /minidlna/cache && \
    chmod 777 /etc/minidlna.conf /minidlna

# Run as user
USER "$USERNAME"

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

# Health check
HEALTHCHECK --interval=10s --timeout=10s --retries=6 CMD \
  curl --silent --fail localhost:8200 || exit 1

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.opencontainers.image.title="VGH MiniDLNA" \
      org.opencontainers.image.url="$VCS_URL" \
      org.opencontainers.image.authors="Vlad Ghinea" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.version="$VERSION" \
      org.opencontainers.image.source="$VCS_URL" \
      org.opencontainers.image.revision="$VCS_REF" \
      org.opencontainers.image.created="$BUILD_DATE"
