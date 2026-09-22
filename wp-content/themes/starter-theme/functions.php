<?php
/**
 * Starter Theme functions.
 *
 * @package Starter_Theme
 */

defined( 'ABSPATH' ) || exit;

require_once get_template_directory() . '/inc/nav-walker.php';
require_once get_template_directory() . '/inc/recommended-plugins.php';

/**
 * Configure theme supports and menus.
 */
function starter_theme_setup(): void {
	add_theme_support( 'title-tag' );
	add_theme_support( 'post-thumbnails' );
	add_theme_support( 'responsive-embeds' );
	add_theme_support( 'editor-styles' );
	add_theme_support(
		'html5',
		[ 'search-form', 'comment-form', 'comment-list', 'gallery', 'caption', 'style', 'script' ]
	);

	register_nav_menus(
		[
			'primary' => __( 'Primary navigation', 'starter-theme' ),
			'footer'  => __( 'Footer navigation', 'starter-theme' ),
		]
	);
}
add_action( 'after_setup_theme', 'starter_theme_setup' );

/**
 * Tell the theme whether to use Vite's local development server.
 */
function starter_theme_is_vite_dev(): bool {
	return wp_get_environment_type() === 'local' && defined( 'WP_DEBUG' ) && WP_DEBUG;
}

/**
 * Get the configured local Vite origin.
 */
function starter_theme_vite_origin(): string {
	$port = getenv( 'VITE_PORT' ) ?: '5173';
	return 'http://localhost:' . absint( $port );
}

/**
 * Enqueue development assets or a compiled production bundle.
 */
function starter_theme_enqueue_assets(): void {
	if ( starter_theme_is_vite_dev() ) {
		$origin = starter_theme_vite_origin();
		wp_enqueue_script( 'starter-theme-vite-client', $origin . '/@vite/client', [], null, false );
		wp_enqueue_script( 'starter-theme-app', $origin . '/src/js/app.js', [], null, true );
		return;
	}

	$manifest_path = get_theme_file_path( '/dist/manifest.json' );
	if ( ! file_exists( $manifest_path ) ) {
		return;
	}

	$manifest = json_decode( file_get_contents( $manifest_path ), true );
	$entry    = is_array( $manifest ) ? ( $manifest['src/js/app.js'] ?? null ) : null;
	if ( ! is_array( $entry ) ) {
		return;
	}

	foreach ( $entry['css'] ?? [] as $index => $css_file ) {
		wp_enqueue_style( 'starter-theme-app-' . $index, get_theme_file_uri( '/dist/' . $css_file ), [], null );
	}

	if ( ! empty( $entry['file'] ) ) {
		wp_enqueue_script( 'starter-theme-app', get_theme_file_uri( '/dist/' . $entry['file'] ), [], null, true );
	}
}
add_action( 'wp_enqueue_scripts', 'starter_theme_enqueue_assets' );

/**
 * Mark Vite-managed scripts as ES modules.
 */
function starter_theme_module_scripts( string $tag, string $handle, string $src ): string {
	if ( ! in_array( $handle, [ 'starter-theme-vite-client', 'starter-theme-app' ], true ) ) {
		return $tag;
	}

	return sprintf( '<script type="module" src="%s"></script>', esc_url( $src ) );
}
add_filter( 'script_loader_tag', 'starter_theme_module_scripts', 10, 3 );
