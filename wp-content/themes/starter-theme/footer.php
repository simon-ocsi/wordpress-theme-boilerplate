<?php
/**
 * Site footer.
 *
 * @package Starter_Theme
 */
?>
</main>
<footer class="mt-20 border-t border-slate-200 bg-slate-50">
	<div class="mx-auto flex max-w-7xl flex-col gap-6 px-6 py-10 lg:flex-row lg:items-center lg:justify-between lg:px-8">
		<p class="text-sm text-slate-600">&copy; <?php echo esc_html( gmdate( 'Y' ) ); ?> <?php bloginfo( 'name' ); ?></p>
		<?php
		wp_nav_menu(
			[
				'theme_location' => 'footer',
				'container'      => false,
				'menu_class'     => 'flex flex-wrap gap-x-5 gap-y-2 text-sm text-slate-600',
				'fallback_cb'    => false,
			]
		);
		?>
	</div>
</footer>
<?php wp_footer(); ?>
</body>
</html>
