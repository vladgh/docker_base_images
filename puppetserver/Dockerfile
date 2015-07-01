FROM ubuntu:14.04
MAINTAINER Vlad Ghinea vlad@ghn.me

ENV DEB="puppetlabs-release-pc1-trusty.deb"
RUN apt-get update -y && \
    apt-get install -y wget && \
    wget -O /tmp/${DEB} https://apt.puppetlabs.com/${DEB} && \
    dpkg -i /tmp/${DEB} && \
    apt-get update -y && apt-get install -y puppetserver && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV HOME='/opt/puppetlabs/server/data/puppetserver' \
    JAVA_ARGS="-Xms256m -Xmx512m"
RUN sed -i "s/JAVA_ARGS=.*/JAVA_ARGS=\"${JAVA_ARGS}\"/g" \
    /etc/default/puppetserver

EXPOSE 8140
ENTRYPOINT ["/opt/puppetlabs/bin/puppetserver"]
CMD ["foreground"]
