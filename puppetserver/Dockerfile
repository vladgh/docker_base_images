FROM ubuntu:14.04
MAINTAINER Vlad Ghinea vlad@ghn.me

WORKDIR /tmp

RUN DEBIAN_FRONTEND=noninteractive apt-get update -qy && \
  DEBIAN_FRONTEND=noninteractive apt-get install -qy wget lsb-release && \
  wget https://apt.puppetlabs.com/puppetlabs-release-$(lsb_release -c -s).deb && \
  dpkg -i puppetlabs-release-$(lsb_release -c -s).deb && \
  DEBIAN_FRONTEND=noninteractive apt-get update -qy && \
  DEBIAN_FRONTEND=noninteractive apt-get install -qy puppetserver supervisor && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 8140
