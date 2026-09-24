FROM mlocati/php-extension-installer:latest AS php-ext-installer

FROM php:8.4-fpm

COPY --from=php-ext-installer /usr/bin/install-php-extensions /usr/bin/install-php-extensions

RUN install-php-extensions \
    pdo_mysql \
    mysqli \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    intl \
    opcache \
    redis \
    xml \
    curl \
    fileinfo \
    dom \
    tokenizer \
    sodium

RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libpng-dev \
    libzip-dev \
    unzip \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

RUN echo "upload_max_filesize = 64M" >> "$PHP_INI_DIR/conf.d/custom.ini" && \
    echo "post_max_size = 64M" >> "$PHP_INI_DIR/conf.d/custom.ini" && \
    echo "memory_limit = 256M" >> "$PHP_INI_DIR/conf.d/custom.ini" && \
    echo "max_execution_time = 300" >> "$PHP_INI_DIR/conf.d/custom.ini" && \
    echo "max_input_time = 300" >> "$PHP_INI_DIR/conf.d/custom.ini" && \
    echo "realpath_cache_size = 4096K" >> "$PHP_INI_DIR/conf.d/custom.ini" && \
    echo "realpath_cache_ttl = 600" >> "$PHP_INI_DIR/conf.d/custom.ini" && \
    echo "opcache.enable=1" >> "$PHP_INI_DIR/conf.d/custom.ini" && \
    echo "opcache.memory_consumption=256" >> "$PHP_INI_DIR/conf.d/custom.ini" && \
    echo "opcache.interned_strings_buffer=32" >> "$PHP_INI_DIR/conf.d/custom.ini" && \
    echo "opcache.max_accelerated_files=20000" >> "$PHP_INI_DIR/conf.d/custom.ini" && \
    echo "opcache.revalidate_freq=0" >> "$PHP_INI_DIR/conf.d/custom.ini" && \
    echo "opcache.validate_timestamps=0" >> "$PHP_INI_DIR/conf.d/custom.ini" && \
    echo "opcache.save_comments=1" >> "$PHP_INI_DIR/conf.d/custom.ini" && \
    echo "opcache.jit=1255" >> "$PHP_INI_DIR/conf.d/custom.ini" && \
    echo "opcache.jit_buffer_size=128M" >> "$PHP_INI_DIR/conf.d/custom.ini"

WORKDIR /var/www
# Fresh named volumes (vendor_data/view_data) image se ownership inherit karte hain,
# isliye ye dirs pehle se bane + www-data owned hone chahiye
RUN mkdir -p storage/framework/views storage/framework/sessions storage/framework/cache storage/logs bootstrap/cache \
    && chown -R www-data:www-data /var/www

EXPOSE 9000
CMD ["php-fpm"]
