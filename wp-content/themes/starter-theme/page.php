<?php
/**
 * Page template.
 *
 * @package Starter_Theme
 */
get_header();
while ( have_posts() ) :
	the_post();
	?>
	<article <?php post_class( 'mx-auto max-w-4xl px-6 py-16 lg:px-8' ); ?>>
		<h1 class="text-4xl font-semibold tracking-tight text-slate-950 sm:text-5xl"><?php the_title(); ?></h1>
		<div class="content mt-8"><?php the_content(); ?></div>
	</article>
	<?php
endwhile;
get_footer();
