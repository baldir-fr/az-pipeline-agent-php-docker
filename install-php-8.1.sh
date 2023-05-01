#!/bin/bash
# Inspired by https://github.com/actions/runner-images/blob/main/images/linux/scripts/installers/php.sh

phpVersion=8.1
add-apt-repository ppa:ondrej/php
apt-get update
apt-get install -y -qq --no-install-recommends \
        php$phpVersion \
        php$phpVersion-amqp \
        php$phpVersion-apcu \
        php$phpVersion-bcmath \
        php$phpVersion-bz2 \
        php$phpVersion-cgi \
        php$phpVersion-cli \
        php$phpVersion-common \
        php$phpVersion-curl \
        php$phpVersion-dba \
        php$phpVersion-dev \
        php$phpVersion-enchant \
        php$phpVersion-fpm \
        php$phpVersion-gd \
        php$phpVersion-gmp \
        php$phpVersion-igbinary \
        php$phpVersion-imagick \
        php$phpVersion-imap \
        php$phpVersion-interbase \
        php$phpVersion-intl \
        php$phpVersion-ldap \
        php$phpVersion-mbstring \
        php$phpVersion-memcache \
        php$phpVersion-memcached \
        php$phpVersion-mongodb \
        php$phpVersion-mysql \
        php$phpVersion-odbc \
        php$phpVersion-opcache \
        php$phpVersion-pgsql \
        php$phpVersion-phpdbg \
        php$phpVersion-pspell \
        php$phpVersion-readline \
        php$phpVersion-redis \
        php$phpVersion-snmp \
        php$phpVersion-soap \
        php$phpVersion-sqlite3 \
        php$phpVersion-sybase \
        php$phpVersion-tidy \
        php$phpVersion-xdebug \
        php$phpVersion-xml \
        php$phpVersion-xsl \
        php$phpVersion-yaml \
        php$phpVersion-zip \
        php$phpVersion-zmq

apt-get install -y --no-install-recommends php$phpVersion-pcov

# Disable PCOV, as Xdebug is enabled by default
# https://github.com/krakjoe/pcov#interoperability
phpdismod -v $phpVersion pcov

apt-get install -y --no-install-recommends php-pear

apt-get install -y --no-install-recommends snmp

# Install composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === file_get_contents('https://composer.github.io/installer.sig')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
sudo mv composer.phar /usr/bin/composer
php -r "unlink('composer-setup.php');"

# Add composer bin folder to path
#prependEtcEnvironmentPath '$HOME/.config/composer/vendor/bin'
echo "PATH=.config/composer/vendor/bin" | sudo tee -a /etc/environment
#Create composer folder for user to preserve folder permissions
mkdir -p /etc/skel/.composer

# Install phpunit (for PHP)
wget -q -O phpunit https://phar.phpunit.de/phpunit-8.phar
chmod +x phpunit
mv phpunit /usr/local/bin/phpunit

# ubuntu 20.04 libzip-dev is libzip5 based and is not compatible libzip-dev of ppa:ondrej/php
# see https://github.com/actions/runner-images/issues/1084
rm /etc/apt/sources.list.d/ondrej-*.list
apt-get update
#
#export phpVersion=8.1
#update-alternatives --set php /usr/bin/php$phpVersion
#update-alternatives --set phar /usr/bin/phar$phpVersion
#update-alternatives --set phpdbg /usr/bin/phpdbg$phpVersion
#update-alternatives --set php-cgi /usr/bin/php-cgi$phpVersion
#update-alternatives --set phar.phar /usr/bin/phar.phar$phpVersion
#php -version