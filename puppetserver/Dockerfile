FROM ubuntu:16.04
MAINTAINER Vlad Ghinea vlad@ghn.me

# Environment
ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:/usr/local/bin:$PATH
ENV PUPPETLABS_RELEASE='puppetlabs-release-pc1-xenial'

# Install Puppet release package
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends wget ca-certificates && \
    wget -O "/tmp/${PUPPETLABS_RELEASE}.deb" \
    "https://apt.puppetlabs.com/${PUPPETLABS_RELEASE}.deb" && \
    dpkg -i "/tmp/${PUPPETLABS_RELEASE}.deb" && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install puppetserver
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && apt-get install -y --no-install-recommends puppetserver && \
    sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{JAVA_ARGS:-\1\}@' \
    /etc/default/puppetserver && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose ports
EXPOSE 8140

# Set-up logging
COPY logback.xml request-logging.xml /etc/puppetlabs/puppetserver/

# Configure entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["puppetserver", "foreground"]
