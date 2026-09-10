<?php
/**
 * Site header.
 *
 * @package Starter_Theme
 */
?><!doctype html>
<html <?php language_attributes(); ?>>
<head>
	<meta charset="<?php bloginfo( 'charset' ); ?>">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<?php wp_head(); ?>
</head>
<body <?php body_class( 'bg-white text-slate-900 antialiased' ); ?>>
<?php wp_body_open(); ?>
<header id="site-header" class="sticky top-0 z-40 border-b border-slate-200 bg-white/95 backdrop-blur">
	<div class="mx-auto flex min-h-16 max-w-7xl items-center justify-between gap-6 px-6 lg:px-8">
		<a href="<?php echo esc_url( home_url( '/' ) ); ?>" class="text-lg font-semibold tracking-tight text-slate-950">
			<?php bloginfo( 'name' ); ?>
		</a>

		<button type="button" class="inline-flex size-10 items-center justify-center rounded-md border border-slate-200 lg:hidden" data-menu-toggle aria-expanded="false" aria-controls="primary-menu">
			<span class="sr-only"><?php esc_html_e( 'Toggle navigation', 'starter-theme' ); ?></span>
			<i data-lucide="menu" class="size-5" data-menu-icon-open aria-hidden="true"></i>
			<i data-lucide="x" class="hidden size-5" data-menu-icon-close aria-hidden="true"></i>
		</button>

		<nav id="primary-menu" class="absolute left-0 top-full hidden w-full border-b border-slate-200 bg-white px-6 py-4 lg:static lg:block lg:w-auto lg:border-0 lg:bg-transparent lg:p-0" data-mobile-menu aria-label="<?php esc_attr_e( 'Primary navigation', 'starter-theme' ); ?>">
			<?php
			wp_nav_menu(
				[
					'theme_location' => 'primary',
					'container'      => false,
					'menu_class'     => 'flex flex-col gap-1 lg:flex-row lg:items-center',
					'fallback_cb'    => false,
					'walker'         => new Starter_Theme_Nav_Walker(),
				]
			);
			?>
		</nav>
	</div>
</header>
<main id="main-content">
