FROM ubuntu:16.04
MAINTAINER Vlad Ghinea vlad@ghn.me

# Environment
ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:/usr/local/bin:$PATH \
    PUPPETLABS_RELEASE='puppetlabs-release-pc1-xenial' \
    PUPPET_SERVER_VERSION="2.5.0" \
    JAVA_ARGS="-Xms512m -Xmx512m"

# Installation
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends wget ca-certificates && \
    wget -O "/tmp/${PUPPETLABS_RELEASE}.deb" \
    "https://apt.puppetlabs.com/${PUPPETLABS_RELEASE}.deb" && \
    dpkg -i "/tmp/${PUPPETLABS_RELEASE}.deb" && \
    apt-get install -y --no-install-recommends \
    puppetserver="$PUPPET_SERVER_VERSION"-1puppetlabs1 && \
    sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{JAVA_ARGS:-\1\}@' \
    /etc/default/puppetserver && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Ports
EXPOSE 8140

# Logging
COPY logback.xml request-logging.xml /etc/puppetlabs/puppetserver/

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["puppetserver", "foreground"]
