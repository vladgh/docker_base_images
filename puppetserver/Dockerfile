FROM ubuntu:16.04
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Environment
ENV PATH=/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:/opt/puppetlabs/server/bin:/usr/local/bin:$PATH \
    PUPPET_RELEASE="puppet-release-xenial" \
    PUPPET_AGENT_VERSION="5.4.0" \
    PUPPETSERVER_VERSION="5.2.0" \
    PUPPETSERVER_JAVA_ARGS="-Xms128M -Xmx512M" \
    TINI_VERSION="0.17.0"

# Installation
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && apt-get install -y --no-install-recommends ca-certificates lsb-release wget && \
    wget -O "/tmp/${PUPPET_RELEASE}.deb" \
    "https://apt.puppetlabs.com/${PUPPET_RELEASE}.deb" && \
    dpkg -i "/tmp/${PUPPET_RELEASE}.deb" && apt-get update -y && \
    apt-get install -y --no-install-recommends \
    puppet-agent="${PUPPET_AGENT_VERSION}"-1xenial \
    puppetserver="$PUPPETSERVER_VERSION"-1xenial && \
    sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{PUPPETSERVER_JAVA_ARGS:-\1\}@' \
    /etc/default/puppetserver && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Tini
ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini /sbin/tini
RUN chmod +x /sbin/tini

# Ports
EXPOSE 8140

# Copy configuration files
COPY logback.xml request-logging.xml /etc/puppetlabs/puppetserver/

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["puppetserver", "foreground"]

# Health check
HEALTHCHECK --interval=10s --timeout=10s --retries=90 CMD \
  curl --fail -H 'Accept: pson' \
  --resolve 'puppet:8140:127.0.0.1' \
  --cert "/etc/puppetlabs/puppet/ssl/certs/$(hostname).pem" \
  --key "/etc/puppetlabs/puppet/ssl/private_keys/$(hostname).pem" \
  --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem \
  https://puppet:8140/production/status/test \
  |  grep -q '"is_alive":true' \
  || exit 1

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.name="VGH Puppet Server" \
      org.label-schema.url="$VCS_URL" \
      org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
