<?php
/**
 * 404 template.
 *
 * @package Starter_Theme
 */
get_header();
?>
<section class="mx-auto max-w-4xl px-6 py-24 text-center lg:px-8">
	<p class="text-sm font-semibold uppercase tracking-widest text-brand-700">404</p>
	<h1 class="mt-4 text-4xl font-semibold tracking-tight text-slate-950 sm:text-5xl"><?php esc_html_e( 'Page not found', 'starter-theme' ); ?></h1>
	<p class="mx-auto mt-5 max-w-xl text-lg text-slate-600"><?php esc_html_e( 'The page you are looking for may have moved or no longer exists.', 'starter-theme' ); ?></p>
	<a class="btn btn-primary mt-8" href="<?php echo esc_url( home_url( '/' ) ); ?>"><?php esc_html_e( 'Return home', 'starter-theme' ); ?></a>
</section>
<?php get_footer(); ?>
