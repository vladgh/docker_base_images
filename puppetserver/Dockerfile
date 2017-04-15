FROM vladgh/puppet:latest
MAINTAINER Vlad Ghinea vlad@ghn.me

# Environment
ENV PATH=/opt/puppetlabs/server/bin:$PATH \
    PUPPETSERVER_VERSION="2.7.2" \
    PUPPETSERVER_JAVA_ARGS="-Xms256m -Xmx256m"

# Installation
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && apt-get install -y --no-install-recommends \
    puppetserver="$PUPPETSERVER_VERSION"-1puppetlabs1 && \
    sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{PUPPETSERVER_JAVA_ARGS:-\1\}@' \
    /etc/default/puppetserver && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Ports
EXPOSE 8140

# Logging
COPY logback.xml request-logging.xml /etc/puppetlabs/puppetserver/

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["puppetserver", "foreground"]

# Health check
HEALTHCHECK --interval=30s --timeout=30s --retries=20 CMD \
  curl --fail -H 'Accept: pson' \
  --cert   $(puppet config print hostcert) \
  --key    $(puppet config print hostprivkey) \
  --cacert $(puppet config print localcacert) \
  https://$(hostname):8140/production/status/test \
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
