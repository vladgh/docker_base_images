FROM ubuntu:xenial
MAINTAINER Vlad Ghinea vlad@ghn.me

# Environment
ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:/usr/local/bin:$PATH

# Install Puppet release package
RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && apt-get install -y --no-install-recommends \
    wget ca-certificates python-pip python-setuptools python-wheel && \
    release_deb="puppetlabs-release-pc1-trusty.deb" && \
    wget -O /tmp/${release_deb} https://apt.puppetlabs.com/${release_deb} && \
    dpkg -i /tmp/${release_deb} && \
    apt-get --purge -y remove wget ca-certificates && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install git and puppetserver
RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && apt-get install -y --no-install-recommends git puppetserver && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install gems
RUN gem install r10k aws-sdk --no-ri --no-rdoc

# Install AWS Command Line Interface
RUN pip install --upgrade pip setuptools awscli

# JAVA_ARGS tuning
RUN sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{JAVA_ARGS:-\1\}@' /etc/default/puppetserver

# Expose ports
EXPOSE 8140

# Configure entrypoint
COPY /entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["puppetserver", "foreground"]
