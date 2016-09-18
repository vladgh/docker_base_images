FROM ubuntu:trusty
MAINTAINER Vlad Ghinea vlad@ghn.me

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository ppa:deluge-team/ppa && \
    apt-get update -q && \
    apt-get install -qy deluged deluge-web && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 8112

ENV USER_ID=1000

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.url="$VCS_URL" \
      org.label-schema.name="Deluge" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
