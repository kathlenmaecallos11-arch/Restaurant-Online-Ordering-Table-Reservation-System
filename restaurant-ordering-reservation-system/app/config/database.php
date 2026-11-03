<?php
declare(strict_types=1);

/**
 * ============================================================================
 *  STEP 1 OF 3  --  POSTGRESQL CONNECTION SETTINGS  (the only place to edit)
 * ============================================================================
 * Nothing secret is written here. Each value is read from the local, uncommitted
 * file  .env  in the repository root (copy .env.example to .env and edit it):
 *
 *     DB_HOST=localhost                      <- where PostgreSQL runs
 *     DB_PORT=5432                           <- PostgreSQL port
 *     DB_NAME=grp_binarysisters_projectdb    <- database created by database/setup.*
 *     DB_USER=rors_app                       <- least-privilege account (never postgres)
 *     DB_PASSWORD=the-password-you-chose     <- set by database/roles/03_set_passwords.psql
 *     DB_SSLMODE=prefer                      <- use "require" on a hosted database
 *
 * The second argument of env() is only a fallback when .env has no such line.
 * This array is read by db() in app/src/db.php (STEP 2), which opens the connection.
 */
return [
    'driver'   => 'pgsql',
    'host'     => env('DB_HOST', 'localhost'),
    'port'     => env('DB_PORT', '5432'),
    'database' => env('DB_NAME', 'grp_binarysisters_projectdb'),
    'username' => env('DB_USER', 'rors_app'),
    'password' => env('DB_PASSWORD', ''),
    'sslmode'  => env('DB_SSLMODE', 'prefer'),
    'app_name' => 'rors-web',   // shown in pg_stat_activity so you can recognise the app's sessions
];
