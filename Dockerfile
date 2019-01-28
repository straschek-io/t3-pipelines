FROM php:7.2

RUN apt-get update \
	&& apt-get install -y locales locales-all
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV COMPOSER_ALLOW_SUPERUSER 1

RUN set -x \
    && apt-get update -y \
    && apt-get install ruby-dev rubygems openssh-client apt-transport-https sudo git rsync zip unzip -yqq --no-install-recommends \
	&& apt-get install gnupg -yqq --no-install-recommends

RUN gem install sass

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global config minimum-stability beta \
    && composer global require typo3/surf:dev-master

RUN composer global require deployer/deployer

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
	&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN	curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

RUN apt-get update -y \
	&& apt-get install -y nodejs yarn

RUN sudo npm install -g grunt-cli
RUN npm install -g bower --allow-root

RUN rm -rf /var/lib/apt/lists/*

# confirm installation
RUN php -v
RUN composer --version
RUN sass -v
RUN node -v
RUN npm -v
RUN yarn -v
