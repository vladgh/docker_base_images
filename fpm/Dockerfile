FROM php:7-fpm
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev libjpeg-dev libxml2-dev libmcrypt-dev \
    libcurl4-gnutls-dev zlib1g-dev libicu-dev \
    libncurses5-dev libtidy-dev libzip-dev msmtp msmtp-mta && \
    apt-get -y autoremove && apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-install -j"$(nproc)" gd intl mysqli soap zip tidy opcache pdo pdo_mysql

RUN echo "sendmail_path=sendmail -i -t" > /usr/local/etc/php/conf.d/php-sendmail.ini

CMD ["php-fpm"]

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.opencontainers.image.title="VGH PHP FPM" \
      org.opencontainers.image.url="$VCS_URL" \
      org.opencontainers.image.authors="Vlad Ghinea" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.version="$VERSION" \
      org.opencontainers.image.source="$VCS_URL" \
      org.opencontainers.image.revision="$VCS_REF" \
      org.opencontainers.image.created="$BUILD_DATE"
