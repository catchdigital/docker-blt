FROM php:5.6-fpm

MAINTAINER Alberto Conteras <a.contreras@catchdigital.com>

RUN apt-get update && apt-get install -y git
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $buildDeps

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer global require "hirak/prestissimo:^0.3"
RUN composer global require "drupal/console:~1@dev"
RUN composer global require "acquia/blt:^8.3"

COPY ./blt /usr/local/bin/blt
RUN chmod +x /usr/local/bin/blt

WORKDIR /var/www

RUN usermod -u 1000 www-data  
RUN usermod -a -G users www-data

RUN chown -R www-data:www-data /var/www

CMD [ "blt" ]
