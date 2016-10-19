FROM php:5.6-fpm

MAINTAINER Alberto Conteras <a.contreras@catchdigital.com>

# Install dependencies
RUN apt-get update && apt-get install -y git rsync zip unzip ssh
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $buildDeps

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add require modules for blt
RUN composer global require "hirak/prestissimo:^0.3"
RUN composer global require "drupal/console:~1@dev"
RUN composer global require "acquia/blt:^8.3"

# Add blt as global
COPY ./blt /usr/local/bin/blt
RUN chmod +x /usr/local/bin/blt

# Set directory and working permissions
WORKDIR /var/www

RUN usermod -u 1000 www-data  
RUN usermod -a -G users www-data

RUN chown -R www-data:www-data /var/www

# Add enviromental vars and git global config
RUN echo 'git config --global core.name $GIT_NAME' >> ~/.bashrc
RUN echo 'git config --global core.email $GIT_EMAIL' >> ~/.bashrc
RUN echo 'git config --global core.fileMode false' >> ~/.bashrc

CMD [ "blt" ]
