FROM ubuntu:xenial
MAINTAINER Vlad Ghinea vlad@ghn.me

# Environment
ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:/usr/local/bin:$PATH \
    PUPPETLABS_RELEASE='puppetlabs-release-pc1-xenial'

# Install Puppet release package
RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y wget && \
    wget -O /tmp/${PUPPETLABS_RELEASE}.deb \
    https://apt.puppetlabs.com/${PUPPETLABS_RELEASE}.deb && \
    dpkg -i /tmp/${PUPPETLABS_RELEASE}.deb && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install git and puppetserver
RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && apt-get install -y --no-install-recommends puppetserver && \
    sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{JAVA_ARGS:-\1\}@' \
    /etc/default/puppetserver && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install extras (Gems, Python packages)
RUN gem install aws-sdk --no-ri --no-rdoc

# Expose ports
EXPOSE 8140

# Configure entrypoint
COPY /entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["puppetserver", "foreground"]
