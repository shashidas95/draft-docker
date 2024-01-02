FROM php:8.2.11-fpm

# Install composer
RUN cd /tmp \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

RUN docker-php-ext-install pdo pdo_mysql

RUN apt-get update

# Install useful tools
RUN apt-get -y install apt-utils nano wget dialog vim

# Install important libraries
RUN apt-get -y install --fix-missing \
    apt-utils \
    build-essential \
    git \
    curl \
    libcurl4 \
    libcurl4-openssl-dev \
    zlib1g-dev \
    libzip-dev \
    zip \
    libbz2-dev \
    locales \
    libmcrypt-dev \
    libicu-dev \
    libonig-dev \
    libxml2-dev

# Install image processing library (GD in this case)
RUN apt-get update \
    && apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Enable file uploads
RUN echo "file_uploads = On\n" >> /usr/local/etc/php/conf.d/uploads.ini

# Set max upload size and post size
RUN echo "upload_max_filesize = 20M\n" >> /usr/local/etc/php/conf.d/uploads.ini
RUN echo "post_max_size = 20M\n" >> /usr/local/etc/php/conf.d/uploads.ini

# Restart PHP-FPM
RUN service php8.2-fpm restart
# RUN echo "\e[1;33mInstall important docker dependencies\e[0m"
# RUN docker-php-ext-install \
#     exif \
#     pcntl \
#     bcmath \
#     ctype \
#     curl \
#     iconv \
#     xml \
#     soap \
#     pcntl \
#     mbstring \
#     tokenizer \
#     bz2 \
#     zip \
#     intl

# Install Postgre PDO
# RUN apt-get install -y libpq-dev \
#     && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
#     && docker-php-ext-install pdo pdo_pgsql pgsql

# Switch to a Node.js image for asset compilation
FROM node:14 AS node
# Install Node.js dependencies
RUN npm install
# Build your Vite project
RUN npm run dev
# Switch back to the PHP image
FROM php:8.2.11-fpm
