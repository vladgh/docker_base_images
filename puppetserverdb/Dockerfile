FROM vladgh/puppetserver:latest
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Environment
ENV PUPPETDB_TERMINUS_VERSION="6.0.0"

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
LABEL org.label-schema.name="VGH Puppet Server with PuppetDB" \
      org.label-schema.url="$VCS_URL" \
      org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
