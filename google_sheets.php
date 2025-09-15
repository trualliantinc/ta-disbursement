<?php
require __DIR__ . '/vendor/autoload.php';

use Google\Client as GoogleClient;
use Google\Service\Sheets;

/** Pull JSON creds from one of several env var names and return decoded array */
function gs_read_env_config(): array {
    $candidates = ['GOOGLE_CREDENTIALS', 'GOOGLE_CREDENTlALS', 'GOOGLE_SERVICE_JSON']; // supports your typo
    foreach ($candidates as $name) {
        $raw = getenv($name);
        if ($raw && trim($raw) !== '') {
            $cfg = json_decode($raw, true);
            if (json_last_error() === JSON_ERROR_NONE) return $cfg;
            throw new RuntimeException("$name is not valid JSON: " . json_last_error_msg());
        }
    }
    throw new RuntimeException(
        'Missing Google credentials; set env var GOOGLE_CREDENTIALS with your service account JSON.'
    );
}

function gs_service(): Sheets {
    $config = gs_read_env_config();

    $client = new GoogleClient();
    $client->setApplicationName('TA-Disbursement');
    $client->setScopes([Sheets::SPREADSHEETS]);
    $client->setAuthConfig($config); // pass array (no file)
    $client->setAccessType('offline');

    return new Sheets($client);
}
