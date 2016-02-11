FROM ubuntu:trusty
MAINTAINER Vlad Ghinea vlad@ghn.me

RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository ppa:deluge-team/ppa && \
    apt-get update -q && apt-get install -qy deluged deluge-web && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD run.sh /run.sh

VOLUME ["/data"]

EXPOSE 8112 53160 53160/udp 58846

ENTRYPOINT ["/bin/bash", "/run.sh"]
