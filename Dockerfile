# --- Base image with Apache + PHP 8.2 ---
FROM php:8.2-apache

# System deps (zip is needed by Composer), enable useful apache modules
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev \
 && docker-php-ext-install zip \
 && a2enmod rewrite headers expires

# (Optional) If you use PDO/MySQL elsewhere, uncomment:
# RUN docker-php-ext-install pdo pdo_mysql

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working dir
WORKDIR /var/www/html

# Copy only composer files first (for better Docker layer caching)
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-progress || true

# Copy the rest of the app
COPY . .

# Apache: allow .htaccess overrides if you use them
RUN sed -ri 's!/var/www/html!/var/www/html!g' /etc/apache2/sites-available/000-default.conf \
 && printf "<Directory /var/www/html>\n    AllowOverride All\n    Require all granted\n</Directory>\n" > /etc/apache2/conf-available/app-htaccess.conf \
 && a2enconf app-htaccess

# Startup script lets Apache listen on $PORT (Render provides it)
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Default port if none provided (Render sets $PORT)
ENV PORT=10000

# Expose for local testing (Render ignores EXPOSE but it's nice for dev)
EXPOSE 10000

CMD ["bash", "/usr/local/bin/start.sh"]
