# PHP-FPM runtime + extensions come from the pre-built base image (php-base:local),
# which was created from the original Dockerfile (see Dockerfile.orig). This avoids
# re-running install-php-extensions (which needs slow network) on every build.
# Only the application code is baked here via COPY for native-speed file reads.
FROM php-base:local

# mysqldump — spatie/laravel-backup (W2.15 daily DB backups) ke liye chahiye.
# ssl=0: MariaDB client MySQL 8 ke self-signed cert par TLS error deta tha.
RUN apk add --no-cache mysql-client \
    && printf '[client]\nssl=0\n\n[mysqld]\nsymbolic-links=0\n\n!includedir /etc/my.cnf.d\n' > /etc/my.cnf

WORKDIR /var/www

# Code ko image me bake karo (Windows bind-mount hata kar native-speed file reads).
# .dockerignore vendor/.env/storage-volatile/static-assets exclude karta hai —
# vendor & compiled views & storage-app named volumes se aate hain.
COPY . /var/www

# Named volumes (vendor_data/view_data/storage_app) image se ownership inherit karte hain,
# isliye ye dirs pehle se bane + www-data owned hone chahiye
RUN mkdir -p storage/framework/views storage/framework/sessions storage/framework/cache storage/logs bootstrap/cache \
    && chown -R www-data:www-data /var/www

EXPOSE 9000
CMD ["php-fpm"]
