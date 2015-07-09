FROM ubuntu:14.04
MAINTAINER Vlad Ghinea vlad@ghn.me

ENV JAVA_ARGS="-Xms256m -Xmx512m" \
    PATH=/opt/puppetlabs/bin/:$PATH

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && apt-get install -y wget && \
    release_deb="puppetlabs-release-pc1-trusty.deb" && \
    wget -O /tmp/${release_deb} https://apt.puppetlabs.com/${release_deb} && \
    dpkg -i /tmp/${release_deb} && \
    apt-get update -y && apt-get install -y puppetserver && \
    sed -i "s/JAVA_ARGS=.*/JAVA_ARGS=\"${JAVA_ARGS}\"/g" \
    /etc/default/puppetserver && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 8140
ENTRYPOINT ["puppetserver"]
CMD ["foreground"]
