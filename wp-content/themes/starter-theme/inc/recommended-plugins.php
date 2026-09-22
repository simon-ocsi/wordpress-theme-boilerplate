<?php
/**
 * Register optional plugins recommended by the starter theme.
 *
 * @package Starter_Theme
 */

defined( 'ABSPATH' ) || exit;

require_once get_template_directory() . '/inc/tgmpa/class-tgm-plugin-activation.php';

/**
 * Recommend development helpers without making them theme dependencies.
 */
function starter_theme_register_recommended_plugins(): void {
	tgmpa(
		[
			[
				'name'     => 'WP Migrate Lite',
				'slug'     => 'wp-migrate-db',
				'required' => false,
			],
		],
		[
			'id'           => 'starter-theme',
			'menu'         => 'starter-theme-install-plugins',
			'has_notices'  => true,
			'dismissable'  => true,
			'is_automatic' => false,
		]
	);
}
add_action( 'tgmpa_register', 'starter_theme_register_recommended_plugins' );
