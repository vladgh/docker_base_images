FROM almir/webhook:2.6.4
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Install packages
RUN apk --no-cache add bash curl tini

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.name="VGH Webhook" \
      org.label-schema.url="$VCS_URL" \
      org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
