# Deploying your PHP + Google Sheets app to Render

This repo is set up to run on **Render** as a Dockerized PHP (Apache) web service.

## Files added
- `Dockerfile` – containerizes your app using `php:8.2-apache`, installs dependencies.
- `start-apache.sh` – optional script to write Google service account JSON from env to `credentials.json`.
- `render.yaml` – Infrastructure-as-code for Render. When pushed to GitHub, Render auto-detects it.
- `.env.example` – a guide for environment variables to set in Render.
- `.htaccess` – optional Apache hardening and rewrite rules.

## Quick Start
1. **Move your app** into a Git repo (keep the `ta-disbursement/` directory at the root).
2. Add the files from this deployment pack to the repo root.
3. Commit & push to GitHub/GitLab.
4. In Render, click **New → Web Service → Build from a repo** and select this repo.
5. Render will detect `render.yaml` and use the Dockerfile automatically.
6. In the service **Environment** tab, add env vars:
   - `ADMIN_USER` and `ADMIN_PASS` (to replace hardcoded creds if you update your `login.php`).
   - `SHEETS_SPREADSHEET_ID` (optional; use it if you remove the hardcoded sheet ID).
   - `GOOGLE_CREDENTIALS_JSON` – paste your service account JSON (multi-line OK).
7. **IAM permissions**: share the target Google Sheet with the service account email from your JSON.
8. **Deploy**. Logs: *Events → View Logs*.

## Optional (recommended) code edits

- **Use env for creds instead of hardcoded values.**
  In `login.php` replace:
  ```php
  $validUser = 'admin';
  $validPass = '1234';
  ```
  with:
  ```php
  $validUser = getenv('ADMIN_USER') ?: 'admin';
  $validPass = getenv('ADMIN_PASS') ?: '1234';
  ```

- **Use env for Spreadsheet ID.**
  In `submitVoucher.php` replace the hardcoded `$spreadsheetId = '...';` with:
  ```php
  $spreadsheetId = getenv('SHEETS_SPREADSHEET_ID') ?: 'PUT-FALLBACK-HERE';
  ```

- **Service account credentials file.**
  Your current code uses:
  ```php
  $client->setAuthConfig(__DIR__ . '/credentials.json');
  ```
  With this pack, you can either:
  - Keep `credentials.json` in the repo (not recommended), or
  - Set `GOOGLE_CREDENTIALS_JSON` in Render and let `start-apache.sh` write `credentials.json` at runtime.

## Common Render fixes
- **Sessions**: We set `session.save_path=/tmp` and ensure the container can write to it.
- **Port**: Render expects your app to listen on `$PORT` (we map Apache to 8080).
- **Health check**: We configured `/login.php`. Change it if your app's home is different.
- **Permissions**: Ensure the service account has Editor access to the target Google Sheet.

## Local test
You can run this Docker image locally:
```bash
docker build -t ta-disbursement .
docker run -p 8080:8080 \
  -e ADMIN_USER=admin \
  -e ADMIN_PASS=secret \
  -e SHEETS_SPREADSHEET_ID=your_sheet_id \
  -e GOOGLE_CREDENTIALS_JSON="$(cat credentials.json)" \
  ta-disbursement
```
Open http://localhost:8080/login.php
