FROM ubuntu:16.04
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Environment
ENV PATH=/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:/opt/puppetlabs/server/bin:/usr/local/bin:$PATH \
    PUPPET_RELEASE="puppet-release-xenial" \
    PUPPET_AGENT_VERSION="5.4.0" \
    PUPPETDB_VERSION="5.2.0" \
    PUPPETDB_JAVA_ARGS="-Djava.net.preferIPv4Stack=true -Xms128M -Xmx512M" \
    TINI_VERSION="0.16.1"

# Installation
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && apt-get install -y --no-install-recommends \
    ca-certificates lsb-release netcat wget && \
    wget -O "/tmp/${PUPPET_RELEASE}.deb" \
    "https://apt.puppetlabs.com/${PUPPET_RELEASE}.deb" && \
    dpkg -i "/tmp/${PUPPET_RELEASE}.deb" && apt-get update -y && \
    apt-get update -y && apt-get install -y --no-install-recommends \
    puppet-agent="${PUPPET_AGENT_VERSION}"-1xenial \
    puppetdb="${PUPPETDB_VERSION}-1xenial" && \
    sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{PUPPETDB_JAVA_ARGS:-\1\}@' \
    /etc/default/puppetdb && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Tini
ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini /sbin/tini
RUN chmod +x /sbin/tini

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
  curl --fail -X GET localhost:8080/pdb/meta/v1/server-time \
  |  grep -q 'server_time' \
  || exit 1

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.name="VGH PuppetDB" \
      org.label-schema.url="$VCS_URL" \
      org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
