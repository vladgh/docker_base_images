FROM php:7-fpm
MAINTAINER Vlad Ghinea vlad@ghn.me

RUN apt-get update && apt-get install -y --no-install-recommends \
      libpng12-dev libjpeg-dev libxml2-dev libmcrypt-dev \
      libcurl4-gnutls-dev zlib1g-dev libicu-dev \
      libncurses5-dev libtidy-dev ssmtp && \
      apt-get -y autoremove && apt-get -y clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-install gd intl mbstring mcrypt mysqli soap zip tidy opcache pdo pdo_mysql

RUN echo "sendmail_path=sendmail -i -t" >> /usr/local/etc/php/conf.d/php-sendmail.ini

CMD ["php-fpm"]
