FROM ubuntu:14.04
MAINTAINER Vlad Ghinea vlad@ghn.me

ENV DEB="puppetlabs-release-pc1-trusty.deb"
RUN apt-get update -qy && \
    apt-get install -qy wget && \
    wget -O /tmp/${DEB} https://apt.puppetlabs.com/${DEB} && \
    dpkg -i /tmp/${DEB} && \
    apt-get update -qy && apt-get install -qy puppetserver && \
    rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

ENV HOME="/opt/puppetlabs/server/data/puppetserver" \
    JAVA_ARGS="-Xms512m -Xmx512m -XX:MaxPermSize=256m"
RUN sed -i "s/JAVA_ARGS=.*/JAVA_ARGS=\"${JAVA_ARGS}\"/g" \
    /etc/default/puppetserver

EXPOSE 8140
ENTRYPOINT ["/opt/puppetlabs/bin/puppetserver"]
CMD ["foreground"]