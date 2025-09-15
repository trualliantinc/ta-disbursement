#!/usr/bin/env bash
set -e

# If you keep your Google or other JSON creds in an env var on Render,
# write them to a file the app expects.
# Example: set GOOGLE_CREDENTIALS on Render to the raw JSON.
if [ -n "$GOOGLE_CREDENTIALS" ]; then
  echo "$GOOGLE_CREDENTIALS" > /var/www/html/credentials.json
fi

# Use $PORT from Render; default to 8080 locally
PORT="${PORT:-8080}"

# Point Apache to the dynamic port
sed -ri "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
sed -ri "s/:80>/:${PORT}>/" /etc/apache2/sites-available/000-default.conf

# Start Apache in foreground
exec apache2-foreground
