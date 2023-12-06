FROM php:8.2

RUN apt-get update \
	&& apt-get install -y locales locales-all
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV COMPOSER_ALLOW_SUPERUSER 1

RUN set -x \
    && apt-get update -y \
    && apt-get install ruby-dev rubygems openssh-client apt-transport-https sudo git rsync zip unzip expect -yqq --no-install-recommends \
	&& apt-get install gnupg -yqq --no-install-recommends

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer global require typo3/surf
RUN composer global require deployer/deployer

RUN apt-get update -y && apt-get install -y nodejs
RUN apt-get update -y && apt-get install -y npm

RUN npm install -g grunt-cli
RUN npm install -g yarn
RUN npm install -g sass

RUN npm install -g n
RUN n 16

RUN rm -rf /var/lib/apt/lists/*

# confirm installation
RUN php -v
RUN composer --version
RUN node -v
RUN sass --version
RUN npm -v
RUN yarn -v
RUN composer global show typo3/surf
RUN composer global show deployer/deployer
