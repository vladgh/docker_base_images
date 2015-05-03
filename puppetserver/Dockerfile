FROM ubuntu:14.04
MAINTAINER Vlad Ghinea vlad@ghn.me

ENV DEB="puppetlabs-release-pc1-trusty.deb"
EXPOSE 8140
WORKDIR /tmp

RUN apt-get update -qy && \
  apt-get install -qy wget && \
  wget https://apt.puppetlabs.com/${DEB} && dpkg -i ${DEB} && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/*

RUN apt-get update -qy && \
  apt-get install -qy puppetserver && \
  rm -rf /var/lib/apt/lists/*

ENTRYPOINT ['/opt/puppetlabs/bin/puppetserver']
CMD ['foreground']
