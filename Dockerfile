# ---- Build stage: install PHP deps ----
FROM composer:2 AS vendor
WORKDIR /app
# Copy only composer files first for better caching
COPY ./ta-disbursement/composer.json ./
# If you prefer to respect composer.lock, uncomment the next line and copy it too
# COPY ./ta-disbursement/composer.lock ./
RUN composer install --no-dev --prefer-dist --no-progress --no-interaction

# ---- Runtime stage: Apache + PHP ----
FROM php:8.2-apache

# Install system packages needed by Google SDKs (curl, zip) and enable PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip \
    && rm -rf /var/lib/apt/lists/*

# Enable recommended Apache modules
RUN a2enmod rewrite headers

# Copy app
WORKDIR /var/www/html
COPY ./ta-disbursement/ .

# Copy vendor from build stage (use this if you don't commit vendor/)
# If your repo already contains vendor/, this will just overwrite with the same content.
COPY --from=vendor /app/vendor/ ./vendor/

# Make sure Apache can write sessions
RUN chown -R www-data:www-data /var/www/html && \
    mkdir -p /var/www/html/storage && chown -R www-data:www-data /var/www/html/storage && \
    mkdir -p /var/log/apache2 && chown -R www-data:www-data /var/log/apache2

# Expose port (Render respects this)
EXPOSE 8080
ENV APACHE_LISTEN_PORT=8080
RUN sed -i 's/80/${APACHE_LISTEN_PORT}/g' /etc/apache2/ports.conf /etc/apache2/sites-available/000-default.conf

# Entry script writes Google credentials from env to a file if provided, then starts Apache
COPY ./start-apache.sh /usr/local/bin/start-apache.sh
RUN chmod +x /usr/local/bin/start-apache.sh

# Set production PHP settings
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    echo "session.save_path=/tmp" >> "$PHP_INI_DIR/php.ini"

CMD ["start-apache.sh"]
