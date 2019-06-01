FROM python:2.7-alpine
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Environment
ENV PUPPETBOARD_VERSION="0.3.0" \
    PUPPETBOARD_PORT="8000" \
    PUPPETBOARD_SETTINGS="docker_settings.py" \
    GUNICORN_VERSION="19.9.0"
WORKDIR /var/www/puppetboard

# Install packages
RUN apk --no-cache add curl tini

# Install pip packages (leave pip installed for importing)
RUN pip --no-cache-dir install puppetboard=="$PUPPETBOARD_VERSION" gunicorn=="$GUNICORN_VERSION"

# Ports
EXPOSE $PUPPETBOARD_PORT

# Entrypoint
ENTRYPOINT ["/sbin/tini", "--"]
CMD /usr/local/bin/gunicorn -b 0.0.0.0:${PUPPETBOARD_PORT} --access-logfile=/dev/stdout puppetboard.app:app

# Health check
HEALTHCHECK --interval=10s --timeout=10s --retries=90 CMD \
  curl --silent --fail -X GET localhost:${PUPPETBOARD_PORT} \
  |  grep -q 'Live from PuppetDB' \
  || exit 1

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.opencontainers.image.title="VGH Puppet Board" \
      org.opencontainers.image.url="$VCS_URL" \
      org.opencontainers.image.authors="Vlad Ghinea" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.version="$VERSION" \
      org.opencontainers.image.source="$VCS_URL" \
      org.opencontainers.image.revision="$VCS_REF" \
      org.opencontainers.image.created="$BUILD_DATE"
