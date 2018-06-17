FROM vladgh/puppet:latest
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Environment
ENV PATH=/opt/puppetlabs/server/bin:$PATH \
    PUPPETSERVER_VERSION="5.3.3" \
    PUPPETSERVER_JAVA_ARGS="-Xms128M -Xmx512M"

# Installation
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && apt-get install -y --no-install-recommends \
    puppetserver="$PUPPETSERVER_VERSION-1xenial" && \
    sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{PUPPETSERVER_JAVA_ARGS:-\1\}@' \
    /etc/default/puppetserver && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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
  curl --silent --fail -H 'Accept: pson' \
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
