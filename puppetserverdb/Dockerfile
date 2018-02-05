FROM ubuntu:16.04
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Environment
ENV PATH=/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:/opt/puppetlabs/server/bin:/usr/local/bin:$PATH \
    PUPPET_RELEASE="puppet-release-xenial" \
    PUPPET_AGENT_VERSION="5.3.4" \
    PUPPETSERVER_VERSION="5.1.4" \
    PUPPETSERVER_JAVA_ARGS="-Xms128M -Xmx512M" \
    PUPPETDB_TERMINUS_VERSION="5.1.3" \
    HIERA_EYAML_VERSION='~> 2.0' \
    TINI_VERSION="0.16.1"

# Installation
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && apt-get install -y --no-install-recommends ca-certificates lsb-release wget && \
    wget -O "/tmp/${PUPPET_RELEASE}.deb" \
    "https://apt.puppetlabs.com/${PUPPET_RELEASE}.deb" && \
    dpkg -i "/tmp/${PUPPET_RELEASE}.deb" && apt-get update -y && \
    apt-get install -y --no-install-recommends \
    puppet-agent="${PUPPET_AGENT_VERSION}"-1xenial \
    puppetserver="$PUPPETSERVER_VERSION"-1xenial \
    puppetdb-termini="$PUPPETDB_TERMINUS_VERSION"-1xenial && \
    sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{PUPPETSERVER_JAVA_ARGS:-\1\}@' \
    /etc/default/puppetserver && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Tini
ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini /sbin/tini
RUN chmod +x /sbin/tini

# Install Hiera EYaml
RUN puppetserver gem install hiera-eyaml:"${HIERA_EYAML_VERSION}" --no-ri --no-rdoc && \
    gem install hiera-eyaml:"${HIERA_EYAML_VERSION}" --no-ri --no-rdoc

# Copy configuration files
COPY hiera.yaml /etc/puppetlabs/puppet/hiera.yaml
COPY logback.xml request-logging.xml /etc/puppetlabs/puppetserver/
COPY puppetdb.conf /etc/puppetlabs/puppet/

# Configure Puppet for PuppetDB
RUN puppet config set storeconfigs_backend puppetdb --section master && \
    puppet config set storeconfigs true --section master && \
    puppet config set reports puppetdb --section master

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["puppetserver", "foreground"]

# Ports
EXPOSE 8140

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.name="VGH Puppet Server with PuppetDB" \
      org.label-schema.url="$VCS_URL" \
      org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
