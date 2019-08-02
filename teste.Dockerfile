FROM ubuntu:bionic
MAINTAINER vizeke <1816558+vizeke@users.noreply.github.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y curl software-properties-common \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y libpng-dev libjpeg-dev nginx php7.2-fpm php7.2-cli php7.2-gd php7.2-mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ADD etc/nginx/nginx.conf /etc/nginx/
ADD etc/nginx/default.conf /etc/nginx/conf.d/
ADD etc/php-fpm/www.conf /etc/php/7.2/fpm/pool.d/
ADD etc/php/wordpress.ini /etc/php/7.2/fpm/conf.d/

ENV WORDPRESS_VERSION 5.2.2
ENV WORDPRESS_SHA1 3605bcbe9ea48d714efa59b0eb2d251657e7d5b0

RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz \
    && echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
    && tar -xzf wordpress.tar.gz -C /usr/src \
    && rm wordpress.tar.gz \
    && chown -R www-data:www-data /usr/src

RUN mkdir -p /var/www/html \
    && cp -pRf /usr/src/wordpress/* /var/www/html/ \
    && cd /var/www/html \
    && mv wp-config-sample.php wp-config.php \
    && sed -ri 's/\r\n|\r//g' wp-config.php