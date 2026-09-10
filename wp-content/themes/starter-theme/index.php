<?php
/**
 * Default template.
 *
 * @package Starter_Theme
 */
get_header();
?>
<section class="mx-auto max-w-4xl px-6 py-16 lg:px-8">
	<?php if ( have_posts() ) : ?>
		<div class="space-y-12">
			<?php while ( have_posts() ) : the_post(); ?>
				<article <?php post_class(); ?>>
					<h2 class="text-2xl font-semibold tracking-tight text-slate-950">
						<a href="<?php the_permalink(); ?>" class="hover:underline"><?php the_title(); ?></a>
					</h2>
					<div class="content mt-4"><?php the_excerpt(); ?></div>
				</article>
			<?php endwhile; ?>
		</div>
		<div class="mt-12"><?php the_posts_pagination(); ?></div>
	<?php else : ?>
		<p><?php esc_html_e( 'No content found.', 'starter-theme' ); ?></p>
	<?php endif; ?>
</section>
<?php get_footer(); ?>
