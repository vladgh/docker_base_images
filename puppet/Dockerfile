FROM ubuntu:16.04
MAINTAINER Vlad Ghinea vlad@ghn.me

# Environment
ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:/usr/local/bin:$PATH
ENV PUPPETLABS_RELEASE='puppetlabs-release-pc1-xenial'

# Install Puppet release package
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends wget ca-certificates lsb-release && \
    wget -O "/tmp/${PUPPETLABS_RELEASE}.deb" \
    "https://apt.puppetlabs.com/${PUPPETLABS_RELEASE}.deb" && \
    dpkg -i "/tmp/${PUPPETLABS_RELEASE}.deb" && apt-get update -y && \
    apt-get install -y --no-install-recommends puppet-agent && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["puppet"]
CMD ["agent", "--verbose", "--onetime", "--no-daemonize", "--summarize"]

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.url="$VCS_URL" \
      org.label-schema.name="Puppet" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
