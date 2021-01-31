FROM wordpress:5.2.2-fpm
LABEL maintainer="1816558+vizeke@users.noreply.github.com"

RUN apt-get update \
    && apt-get install -y nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ADD etc/nginx/nginx.conf /etc/nginx/
ADD etc/nginx/default.conf /etc/nginx/conf.d/
ADD etc/php-fpm/www.conf /usr/local/etc/php-fpm.d/
ADD etc/php/wordpress.ini /usr/local/etc/php/conf.d/

RUN cd /usr/src/wordpress \
    && mv wp-config-sample.php wp-config.php \
    && sed -ri 's/\r\n|\r//g' wp-config.php \
    && mkdir -p /var/log/php-fpm \
    && chown -R www-data:www-data /usr/src \
    && chown www-data:www-data /var/log/php-fpm

EXPOSE 80

ADD docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
