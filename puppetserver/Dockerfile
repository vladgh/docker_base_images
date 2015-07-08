FROM ubuntu:14.04
MAINTAINER Vlad Ghinea vlad@ghn.me

ENV JAVA_ARGS="-Xms256m -Xmx512m"

RUN release_deb="puppetlabs-release-pc1-trusty.deb" && \
    apt-get update -y && apt-get install -y wget && \
    wget -O /tmp/${release_deb} https://apt.puppetlabs.com/${release_deb} && \
    dpkg -i /tmp/${release_deb} && \
    apt-get update -y && apt-get install -y puppetserver && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN sed -i "s/JAVA_ARGS=.*/JAVA_ARGS=\"${JAVA_ARGS}\"/g" \
    /etc/default/puppetserver

EXPOSE 8140
ENTRYPOINT ["/opt/puppetlabs/bin/puppetserver"]
CMD ["foreground"]
