FROM vladgh/puppet:latest
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Environment
ENV PATH=/opt/puppetlabs/server/bin:$PATH \
    PUPPETDB_VERSION="6.0.1" \
    PUPPETDB_JAVA_ARGS="-Djava.net.preferIPv4Stack=true -Xms128M -Xmx512M"

# Installation
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && apt-get install -y --no-install-recommends \
    netcat puppetdb="${PUPPETDB_VERSION}-1bionic" && \
    sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{PUPPETDB_JAVA_ARGS:-\1\}@' \
    /etc/default/puppetdb && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Ports
EXPOSE 8080 8081

# Logging
COPY logging/logback.xml logging/request-logging.xml /etc/puppetlabs/puppetdb/

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["puppetdb", "foreground"]

# Health check
HEALTHCHECK --interval=10s --timeout=10s --retries=90 CMD \
  curl --silent --fail -X GET localhost:8080/pdb/meta/v1/server-time \
  |  grep -q 'server_time' \
  || exit 1

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.opencontainers.image.title="VGH PuppetDB" \
      org.opencontainers.image.url="$VCS_URL" \
      org.opencontainers.image.authors="Vlad Ghinea" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.version="$VERSION" \
      org.opencontainers.image.source="$VCS_URL" \
      org.opencontainers.image.revision="$VCS_REF" \
      org.opencontainers.image.created="$BUILD_DATE"
