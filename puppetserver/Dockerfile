FROM ubuntu:14.04
MAINTAINER Vlad Ghinea vlad@ghn.me

EXPOSE 8140
WORKDIR /tmp

RUN apt-get update -qy && \
  apt-get install -qy wget lsb-release && \
  wget https://apt.puppetlabs.com/puppetlabs-release-pc1-$(lsb_release -c -s).deb && \
  dpkg -i puppetlabs-release-pc1-$(lsb_release -c -s).deb && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/*

RUN apt-get update -qy && \
  apt-get install -qy puppetserver && \
  rm -rf /var/lib/apt/lists/*
