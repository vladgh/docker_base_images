FROM python:2.7-alpine
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Environment
ENV GUNICORN_VERSION="19.7.1" \
    PUPPETBOARD_VERSION="0.2.2" \
    PUPPETBOARD_PORT="8000" \
    PUPPETBOARD_SETTINGS="docker_settings.py"
WORKDIR /var/www/puppetboard

# Install packages
RUN apk --no-cache add curl tini

# Install pip packages (leave pip installed for importing)
RUN pip --no-cache-dir install puppetboard=="$PUPPETBOARD_VERSION" gunicorn=="$GUNICORN_VERSION"

# Ports
EXPOSE $PUPPETBOARD_PORT

# Entrypoint
ENTRYPOINT ["/sbin/tini", "--"]
CMD /usr/bin/gunicorn -b 0.0.0.0:${PUPPETBOARD_PORT} --access-logfile=/dev/stdout puppetboard.app:app

# Health check
HEALTHCHECK --interval=10s --timeout=10s --retries=90 CMD \
  curl --fail -X GET localhost:${PUPPETBOARD_PORT} \
  |  grep -q 'Live from PuppetDB' \
  || exit 1

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.name="VGH Puppet Board" \
      org.label-schema.url="$VCS_URL" \
      org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
