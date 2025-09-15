FROM php:8.2-apache

# System deps + PHP extensions used by google/apiclient
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libicu-dev \
 && docker-php-ext-install zip mbstring intl \
 && a2enmod rewrite \
 && rm -rf /var/lib/apt/lists/*

# Allow .htaccess
RUN printf '<Directory "/var/www/html">\n\tAllowOverride All\n\tRequire all granted\n</Directory>\n' \
    > /etc/apache2/conf-available/allowoverride.conf \
 && a2enconf allowoverride

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
      --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

# Install PHP deps first (better caching)
COPY composer.json ./
# If you have composer.lock, include it too:
# COPY composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-ansi || true

# App code
COPY . .

# Render dynamic port
EXPOSE 8080
CMD sed -ri "s/Listen 80/Listen ${PORT:-8080}/" /etc/apache2/ports.conf \
 && sed -ri "s/:80>/:${PORT:-8080}>/" /etc/apache2/sites-available/000-default.conf \
 && apache2-foreground
