# syntax=docker/dockerfile:1

FROM php:8.2-fpm-bookworm AS php-base

# Install PIE (PHP Installer for Extensions) https://php.github.io/pie/#docs/usage
COPY --from=ghcr.io/php/pie:bin /pie /usr/local/bin/pie

# Install composer from https://hub.docker.com/_/composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN <<EOT
#!/bin/bash
    export DEBIAN_FRONTEND="noninteractive"

    set -eux

    apt-get update

    # Install permanent dependencies
    PERM_DEPS=(
        bash
        git
        libbz2-1.0
        libicu72
        libpq5
        libxml2
        libzip4
        unzip
    )
    apt-get install --yes --no-install-recommends "${PERM_DEPS[@]}"

    # Install build-time dependencies
    BUILD_DEPS=(
        libbz2-dev
        libicu-dev
        libpq-dev
        libtool
        libxml2-dev
        libzip-dev
    )
    apt-get install --yes --no-install-recommends "${BUILD_DEPS[@]}"

    # Install PHP extensions
    PHP_EXTS=(
        bcmath
        bz2
        intl
        opcache
        pcntl
        pdo_pgsql
        soap
        zip
    )
    docker-php-ext-install -j "$(nproc)" "${PHP_EXTS[@]}"

    # https://github.com/docker-library/php/issues/1245
    CFLAGS=${CFLAGS:-""}
    CFLAGS="$CFLAGS -D_GNU_SOURCE" docker-php-ext-install sockets

    pie install pie-extensions/igbinary
    pie install xdebug/xdebug
    docker-php-ext-enable igbinary

    # Remove build-time dependencies
    apt-get remove --yes --purge --auto-remove "${BUILD_DEPS[@]}"
    docker-php-source delete

    # Clean apt cache
    apt-get clean
    rm -rf /var/lib/apt/lists/*

    # Upgrade default shell
    # rm /bin/sh
    # ln -s /bin/bash /bin/sh
EOT

# Create unprivileged user
RUN groupadd appuser \
    && useradd -m -g appuser -s /bin/bash appuser
COPY --chown=appuser:appuser docker/.bashrc /home/appuser/

# Allow Composer to use all available RAM while installing packages
ENV COMPOSER_MEMORY_LIMIT="-1"

WORKDIR /var/www/


FROM php-base AS php-fpm

USER appuser:appuser

CMD ["php-fpm"]
