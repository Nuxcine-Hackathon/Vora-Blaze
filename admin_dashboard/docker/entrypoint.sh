#!/bin/sh
set -e

# Aucun fichier .env n'est embarque dans l'image : les variables viennent de
# l'onglet "Environment" d'EasyPanel (vraies variables d'environnement du
# conteneur). Laravel les lit directement, .env n'est requis a aucun moment.

php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

[ -L public/storage ] || php artisan storage:link

exec "$@"
