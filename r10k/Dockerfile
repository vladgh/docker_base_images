FROM ruby:alpine
MAINTAINER Vlad Ghinea vlad@ghn.me

# Environment
ENV R10K_VERSION='2.4.3'

# Install packages
RUN apk --no-cache add bash git

# Install R10K
RUN gem install r10k --version "$R10K_VERSION" --no-ri --no-rdoc

# Default entrypoint and command
ENTRYPOINT ["r10k"]
CMD ["version"]

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.url="$VCS_URL" \
      org.label-schema.name="R10K" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
