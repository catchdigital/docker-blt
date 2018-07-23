FROM php:7.1-fpm

MAINTAINER Alberto Conteras <a.contreras@catchdigital.com>

# Install dependencies
RUN apt-get update \
    && apt-get install -y git rsync zip unzip ssh libpng-dev libjpeg-dev gnupg2 \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV COMPOSER_HOME '/usr/composer'

# Install node
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get install -y nodejs

# Clean up
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $buildDeps

# Add composer dependencies
RUN composer global require drupal/console acquia/blt

# Add blt as global
RUN export PATH=$COMPOSER_HOME/.composer/vendor/bin:$PATH
RUN ln -s $COMPOSER_HOME/vendor/bin/blt /usr/local/bin/blt

# Set directory and working permissions
WORKDIR /var/www

RUN usermod -u 1000 www-data
RUN usermod -a -G users www-data

RUN chown -R www-data:www-data /var/www

# Add enviromental vars and git global config
RUN echo 'git config --global user.name $GIT_NAME' >> ~/.bashrc
RUN echo 'git config --global user.email $GIT_EMAIL' >> ~/.bashrc
RUN echo 'git config --global core.fileMode false' >> ~/.bashrc
