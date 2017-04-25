FROM php:7.1-fpm
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng12-dev libjpeg-dev libxml2-dev libmcrypt-dev \
    libcurl4-gnutls-dev zlib1g-dev libicu-dev \
    libncurses5-dev libtidy-dev ssmtp && \
    apt-get -y autoremove && apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-install -j"$(nproc)" gd intl mbstring mcrypt mysqli soap zip \
    tidy opcache pdo pdo_mysql

RUN echo "sendmail_path=sendmail -i -t" > /usr/local/etc/php/conf.d/php-sendmail.ini

CMD ["php-fpm"]

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.name="VGH PHP FPM" \
      org.label-schema.url="$VCS_URL" \
      org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
