#!/usr/bin/env bash
set -e

# If GOOGLE_APPLICATION_CREDENTIALS_JSON is provided, write the file:
if [ -n "$GOOGLE_APPLICATION_CREDENTIALS_JSON" ]; then
  echo "$GOOGLE_APPLICATION_CREDENTIALS_JSON" > /app-credentials.json
  export GOOGLE_APPLICATION_CREDENTIALS=/app-credentials.json
fi

# Make Apache listen on $PORT (Render sets this)
sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/:80>/:${PORT}>/" /etc/apache2/sites-available/000-default.conf

# Launch Apache in foreground
exec apache2-foreground
