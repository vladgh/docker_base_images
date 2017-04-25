FROM php:7.1-apache
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Install the PHP extensions we need
RUN apt-get update && \
  apt-get install -y --no-install-recommends libpng12-dev libjpeg-dev \
    libxml2-dev libmcrypt-dev libcurl4-gnutls-dev zlib1g-dev libicu-dev g++ \
    wget libtool apache2-dev libncurses5-dev libtidy-dev && \
  docker-php-ext-install gd intl mbstring mcrypt mysqli soap zip tidy \
    opcache && \
  wget -O /tmp/mod_cloudflare.c https://www.cloudflare.com/static/misc/mod_cloudflare/mod_cloudflare.c && \
  wget -O /tmp/mod_pagespeed_64.deb https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb && \
  apxs2 -a -i -c /tmp/mod_cloudflare.c && \
  touch /etc/default/mod-pagespeed && \
  dpkg -i /tmp/mod_pagespeed_64.deb && apt-get -f install && \
  apt-get --purge -y remove apache2-dev wget && \
  apt-get -y autoremove && apt-get -y clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Modify apache config
RUN a2enmod rewrite && \
    a2enmod expires && \
    a2enmod headers

CMD ["apache2-foreground"]

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.name="VGH Apache" \
      org.label-schema.url="$VCS_URL" \
      org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
