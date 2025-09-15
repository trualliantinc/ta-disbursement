# ---- Build/Runtime ----
FROM php:8.2-cli

# Install extensions needed by google/apiclient (zip) + composer
RUN apt-get update && apt-get install -y --no-install-recommends git unzip libzip-dev \
  && docker-php-ext-install zip \
  && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# App dir
WORKDIR /app

# Only copy composer files first (better layer caching)
COPY prject/composer.json prject/composer.lock ./prject/
RUN cd prject && composer install --no-dev --prefer-dist --no-interaction --no-progress

# Copy the rest of the app
COPY prject ./prject

# Entrypoint writes credentials.json (from env) and starts PHP server
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Render sets $PORT; default to 10000 locally
ENV PORT=10000

EXPOSE 10000
CMD ["/entrypoint.sh"]
