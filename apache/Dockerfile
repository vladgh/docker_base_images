FROM php:5.6-apache
MAINTAINER Vlad Ghinea vlad@ghn.me

# Install the PHP extensions we need
RUN apt-get update && \
  apt-get install -y libpng12-dev libjpeg-dev libxml2 && \
  rm -rf /var/lib/apt/lists/* && \
  docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr && \
  docker-php-ext-install gd && \
  docker-php-ext-install mysqli && \
  docker-php-ext-install soap

# Modify apache config
RUN a2enmod rewrite && \
    a2enmod expires && \
    a2enmod headers

CMD ["apache2-foreground"]
