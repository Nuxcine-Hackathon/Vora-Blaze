FROM php:8.3-apache

# Reduce log noise; the site has no vhost/rewrite needs (plain .php URLs).
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

COPY . /var/www/html/

EXPOSE 80
