FROM php:8.3-apache

# Extensions PHP requises par Laravel 12 + Spatie MediaLibrary + yajra/datatables.
# ext-mongodb et ext-grpc sont volontairement omises : declarees dans composer.json
# mais jamais invoquees par le code applicatif reel (verifie : aucun modele
# n'etend MongoDB\Laravel\Eloquent\Model, aucun controleur n'appelle MongoDB\Client,
# et les classes *Grpc.php sont deja exclues de l'autoload par Composer lui-meme).
# Les compiler ici couterait de longues minutes de build pour rien.
RUN apt-get update && apt-get install -y --no-install-recommends \
        libzip-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev libicu-dev libonig-dev \
        default-mysql-client unzip git \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install -j"$(nproc)" pdo_mysql mbstring exif bcmath gd zip intl \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Apache doit servir public/, pas la racine du projet.
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction \
        --ignore-platform-req=ext-mongodb --ignore-platform-req=ext-grpc \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80
ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"]
