#!/usr/bin/env bash
set -e

# If GOOGLE_APPLICATION_CREDENTIALS_JSON is provided, write it to a file
if [ -n "${GOOGLE_APPLICATION_CREDENTIALS_JSON}" ]; then
  echo "Writing Google credentials to prject/credentials.json"
  printf "%s" "${GOOGLE_APPLICATION_CREDENTIALS_JSON}" > /app/prject/credentials.json
  chmod 600 /app/prject/credentials.json
fi

# Start PHP built-in server serving the prject folder
php -S 0.0.0.0:${PORT:-10000} -t /app/prject
