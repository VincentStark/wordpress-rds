# wordpress-rds

AWS-enabled stateless Wordpress container.

* php-fpm
* nginx mainline
* AWS RDS support

## Features

* High-performance php-fpm + latest nginx
* Works seamlessly with Elastic Beanstalk and RDS
* Fully stateless: WP directory is read-only

## How to use

Sample Dockerfile:
```
FROM vst42/wordpress-rds:latest
ADD plugins /var/www/html/wp-content/
ADD themes /var/www/html/wp-content/
```

Deploy to AWS Elastic Beanstalk with RDS enabled.
