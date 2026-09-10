<?php
/**
 * Local-only WordPress configuration for the boilerplate Docker environment.
 * Do not deploy this file to production unchanged.
 */

defined( 'ABSPATH' ) || define( 'ABSPATH', __DIR__ . '/' );

define( 'DB_NAME', getenv( 'WORDPRESS_DB_NAME' ) ?: 'wordpress' );
define( 'DB_USER', getenv( 'WORDPRESS_DB_USER' ) ?: 'wordpress' );
define( 'DB_PASSWORD', getenv( 'WORDPRESS_DB_PASSWORD' ) ?: 'wordpress' );
define( 'DB_HOST', getenv( 'WORDPRESS_DB_HOST' ) ?: 'db:3306' );
define( 'DB_CHARSET', 'utf8mb4' );
define( 'DB_COLLATE', '' );

define( 'AUTH_KEY',         'local-development-auth-key' );
define( 'SECURE_AUTH_KEY',  'local-development-secure-auth-key' );
define( 'LOGGED_IN_KEY',    'local-development-logged-in-key' );
define( 'NONCE_KEY',        'local-development-nonce-key' );
define( 'AUTH_SALT',        'local-development-auth-salt' );
define( 'SECURE_AUTH_SALT', 'local-development-secure-auth-salt' );
define( 'LOGGED_IN_SALT',   'local-development-logged-in-salt' );
define( 'NONCE_SALT',       'local-development-nonce-salt' );

$table_prefix = 'wp_';

define( 'WP_ENVIRONMENT_TYPE', 'local' );
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', true );
define( 'DISALLOW_FILE_EDIT', true );

$home = getenv( 'WORDPRESS_HOME' ) ?: 'http://localhost:8080';
define( 'WP_HOME', $home );
define( 'WP_SITEURL', $home );

require_once ABSPATH . 'wp-settings.php';
