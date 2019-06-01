FROM ubuntu:18.04
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Environment
ENV PATH=/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:/usr/local/bin:$PATH \
    PUPPET_RELEASE="puppet-release-bionic" \
    PUPPET_AGENT_VERSION="6.0.4" \
    TINI_VERSION="0.18.0"

# Install Puppet release package
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends ca-certificates lsb-release wget && \
    wget -O "/tmp/${PUPPET_RELEASE}.deb" \
    "https://apt.puppetlabs.com/${PUPPET_RELEASE}.deb" && \
    dpkg -i "/tmp/${PUPPET_RELEASE}.deb" && apt-get update -y && \
    apt-get install -y --no-install-recommends puppet-agent="${PUPPET_AGENT_VERSION}-1bionic" && \
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
LABEL org.opencontainers.image.title="VGH Puppet Agent" \
      org.opencontainers.image.url="$VCS_URL" \
      org.opencontainers.image.authors="Vlad Ghinea" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.version="$VERSION" \
      org.opencontainers.image.source="$VCS_URL" \
      org.opencontainers.image.revision="$VCS_REF" \
      org.opencontainers.image.created="$BUILD_DATE"
