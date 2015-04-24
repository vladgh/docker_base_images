FROM php:5-apache
MAINTAINER Vlad Ghinea vlad@ghn.me

# Install the PHP extensions we need
RUN apt-get update && \
  apt-get install -y libpng12-dev libjpeg-dev libxml2-dev libmcrypt-dev \
  wget libtool apache2-dev && \
  docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr && \
  docker-php-ext-install gd && \
  docker-php-ext-install mysqli && \
  docker-php-ext-install soap && \
  docker-php-ext-install mcrypt && \
  wget -O /tmp/mod_cloudflare.c https://www.cloudflare.com/static/misc/mod_cloudflare/mod_cloudflare.c && \
  apxs2 -a -i -c /tmp/mod_cloudflare.c && \
  apt-get --purge -y remove apache2-dev wget && \
  apt-get -y autoremove && apt-get -y clean && rm -rf /var/lib/apt/lists/*
  
# Modify apache config
RUN a2enmod rewrite && \
    a2enmod expires && \
    a2enmod headers

CMD ["apache2-foreground"]
