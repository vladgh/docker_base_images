FROM alpine:3.10
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Install packages
RUN apk --no-cache add bash curl minidlna tini

#Set User to MiniDLNA, to prevent it from running as root user
#We set the read/write permissions to everyone to give the user the possibility to run the container as any desired user
RUN chown minidlna:minidlna /etc/minidlna.conf && chmod ugo+w /etc/minidlna.conf
RUN mkdir /minidlna && chown minidlna:minidlna /minidlna && chmod 777 /minidlna
USER minidlna
RUN mkdir /minidlna/cache && chmod 777 /minidlna/cache

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
