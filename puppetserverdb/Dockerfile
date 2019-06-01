FROM vladgh/puppetserver:latest
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Environment
ENV PUPPETDB_TERMINUS_VERSION="6.0.1"

# Installation
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && apt-get install -y --no-install-recommends \
    puppetdb-termini="$PUPPETDB_TERMINUS_VERSION"-1bionic && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy configuration files
COPY puppetdb.conf /etc/puppetlabs/puppet/

# Configure Puppet for PuppetDB
RUN puppet config set storeconfigs_backend puppetdb --section master && \
    puppet config set storeconfigs true --section master && \
    puppet config set reports puppetdb --section master

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.opencontainers.image.title="VGH Puppet Server with PuppetDB" \
      org.opencontainers.image.url="$VCS_URL" \
      org.opencontainers.image.authors="Vlad Ghinea" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.version="$VERSION" \
      org.opencontainers.image.source="$VCS_URL" \
      org.opencontainers.image.revision="$VCS_REF" \
      org.opencontainers.image.created="$BUILD_DATE"
