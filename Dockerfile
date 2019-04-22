FROM ubuntu:trusty
MAINTAINER vst42 <471022+vst42@users.noreply.github.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y curl \
    && echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list \
    && echo "deb-src http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list \
    && curl -s http://nginx.org/keys/nginx_signing.key | apt-key add - \
    && apt-get update \
    && apt-get install -y \
       libpng12-dev libjpeg-dev nginx php5-fpm php5-cli php5-gd php5-mysqlnd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ADD etc/nginx/nginx.conf /etc/nginx/
ADD etc/nginx/default.conf /etc/nginx/conf.d/
ADD etc/php-fpm/www.conf /etc/php5/fpm/pool.d/
ADD etc/php/wordpress.ini /etc/php5/fpm/conf.d/

ENV WORDPRESS_VERSION 4.5
ENV WORDPRESS_SHA1 439f09e7a948f02f00e952211a22b8bb0502e2e2

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

RUN mkdir -p /var/log/php-fpm \
    && chown nginx:nginx /var/log/php-fpm \
    && chown nginx:nginx -R /var/lib/php5 \
    && chmod 755 /var/lib/php5

EXPOSE 80

ADD docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
