FROM alpine:latest
MAINTAINER Vlad Ghinea vlad@ghn.me

# Install packages
RUN apk --no-cache add bash git gnupg haveged xz python && \
    apk --no-cache add --virtual build-dependencies py-pip && \
    pip install awscli && \
    apk del build-dependencies

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.url="$VCS_URL" \
      org.label-schema.name="Backup" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
