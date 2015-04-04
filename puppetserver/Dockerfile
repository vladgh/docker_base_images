FROM ubuntu:14.04
MAINTAINER Vlad Ghinea vlad@ghn.me

WORKDIR /tmp

RUN apt-get update -y && \
  apt-get install -y wget lsb-release && \
  wget https://apt.puppetlabs.com/puppetlabs-release-$(lsb_release -c -s).deb && \
  dpkg -i puppetlabs-release-$(lsb_release -c -s).deb && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/*

RUN apt-get update -y && \
  apt-get install -y puppetserver && \
  rm -rf /var/lib/apt/lists/*

EXPOSE 8140
