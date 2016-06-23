FROM php:5-fpm
MAINTAINER Vlad Ghinea vlad@ghn.me

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng12-dev libjpeg-dev libxml2-dev libz-dev libmcrypt-dev \
    libcurl4-gnutls-dev zlib1g-dev libicu-dev \
    libncurses5-dev libtidy-dev libmemcached-dev ssmtp && \
    apt-get -y autoremove && apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-install -j$(nproc) gd intl mbstring mcrypt mysqli soap zip \
    tidy opcache pdo pdo_mysql && \
    pecl install memcached && \
    docker-php-ext-enable memcached

RUN echo "sendmail_path=sendmail -i -t" > /usr/local/etc/php/conf.d/php-sendmail.ini

CMD ["php-fpm"]
