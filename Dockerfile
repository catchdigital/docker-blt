FROM php:5.6-fpm

MAINTAINER Alberto Conteras <a.contreras@catchdigital.com>

# Install dependencies
RUN apt-get update && apt-get install -y git rsync zip unzip ssh
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $buildDeps

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add node
ENV NODE_VERSION 0.12.17

RUN buildDeps='xz-utils' \
    && set -x \
    && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
    && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
    && apt-get purge -y --auto-remove $buildDeps \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

# Add composer dependencies
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
RUN echo 'git config --global user.name $GIT_NAME' >> ~/.bashrc
RUN echo 'git config --global user.email $GIT_EMAIL' >> ~/.bashrc
RUN echo 'git config --global core.fileMode false' >> ~/.bashrc

CMD [ "blt" ]
