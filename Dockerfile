# Use PHP + Apache
FROM php:8.2-apache

# Install system deps and Composer
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev \
 && docker-php-ext-install zip \
 && a2enmod rewrite \
 && rm -rf /var/lib/apt/lists/*

# Enable .htaccess overrides
RUN printf '<Directory "/var/www/html">\n\tAllowOverride All\n\tRequire all granted\n</Directory>\n' \
    > /etc/apache2/conf-available/allowoverride.conf \
 && a2enconf allowoverride

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
      --install-dir=/usr/local/bin --filename=composer

# Set workdir
WORKDIR /var/www/html

# Leverage Docker layer cache for Composer
COPY composer.json ./
# (copy lock if you use it; if not, remove next line)
# COPY composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-ansi || true

# Copy the rest of the app
COPY . .

# Provide an entrypoint that adapts Apache to $PORT (Render)
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Default port (Render injects $PORT at runtime; entrypoint switches Apache to it)
EXPOSE 8080

ENTRYPOINT ["docker-entrypoint.sh"]
