FROM ubuntu:trusty
MAINTAINER Vlad Ghinea vlad@ghn.me

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository ppa:deluge-team/ppa && \
    apt-get update -q && apt-get install -qy deluged deluge-web && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
