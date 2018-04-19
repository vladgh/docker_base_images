FROM ubuntu:16.04
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Environment
ENV PATH=/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:/usr/local/bin:$PATH \
    PUPPET_RELEASE="puppet-release-xenial" \
    PUPPET_AGENT_VERSION="5.5.1" \
    TINI_VERSION="0.17.0"

# Install Puppet release package
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends ca-certificates lsb-release wget && \
    wget -O "/tmp/${PUPPET_RELEASE}.deb" \
    "https://apt.puppetlabs.com/${PUPPET_RELEASE}.deb" && \
    dpkg -i "/tmp/${PUPPET_RELEASE}.deb" && apt-get update -y && \
    apt-get install -y --no-install-recommends puppet-agent="${PUPPET_AGENT_VERSION}-1xenial" && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Tini
ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini /sbin/tini
RUN chmod +x /sbin/tini

# Entrypoint
ENTRYPOINT ["/sbin/tini", "--", "puppet"]
CMD ["agent", "--verbose", "--onetime", "--no-daemonize", "--summarize"]

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.name="VGH Puppet Agent" \
      org.label-schema.url="$VCS_URL" \
      org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
