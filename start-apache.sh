#!/usr/bin/env bash
set -euo pipefail

# Optional: write service account JSON from env to file for Google API client
if [[ -n "${GOOGLE_CREDENTIALS_JSON:-}" ]]; then
  echo "$GOOGLE_CREDENTIALS_JSON" > /var/www/html/credentials.json
  chmod 600 /var/www/html/credentials.json
fi

# If you prefer using an env var spreadsheet ID instead of hardcoded one,
# you can read it in PHP with getenv('SHEETS_SPREADSHEET_ID').

apache2-foreground
