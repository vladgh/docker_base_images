FROM vladgh/awscli:latest
MAINTAINER Vlad Ghinea vlad@ghn.me

# Install iNotify tools
RUN apk --no-cache add inotify-tools

# Configure entrypoint
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
      org.label-schema.name="S3 Sync" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
