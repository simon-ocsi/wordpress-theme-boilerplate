<?php
/**
 * Navigation walker with Tailwind-friendly submenu markup.
 *
 * @package Starter_Theme
 */

defined( 'ABSPATH' ) || exit;

class Starter_Theme_Nav_Walker extends Walker_Nav_Menu {
	public function start_lvl( &$output, $depth = 0, $args = null ): void {
		$indent = str_repeat( "\t", $depth );
		$output .= "\n{$indent}<ul class=\"mt-2 hidden space-y-1 border-l border-slate-200 pl-4 lg:absolute lg:left-0 lg:top-full lg:z-50 lg:min-w-56 lg:rounded-lg lg:border lg:bg-white lg:p-2 lg:shadow-lg lg:group-hover:block lg:group-focus-within:block\">\n";
	}

	public function start_el( &$output, $item, $depth = 0, $args = null, $id = 0 ): void {
		$classes = empty( $item->classes ) ? [] : (array) $item->classes;
		$has_children = in_array( 'menu-item-has-children', $classes, true );
		$indent = $depth ? str_repeat( "\t", $depth ) : '';
		$output .= $indent . '<li class="relative lg:group">';

		$link_classes = $depth > 0
			? 'block rounded-md px-3 py-2 text-sm text-slate-700 hover:bg-slate-100 hover:text-slate-950'
			: 'inline-flex items-center gap-1 rounded-md px-3 py-2 text-sm font-medium text-slate-700 hover:text-slate-950';

		$output .= sprintf(
			'<a class="%s" href="%s">%s</a>',
			esc_attr( $link_classes ),
			esc_url( $item->url ),
			esc_html( $item->title )
		);

		if ( $has_children && 0 === $depth ) {
			$output .= '<button class="ml-1 inline-flex size-8 items-center justify-center rounded-md lg:hidden" type="button" data-dropdown-toggle aria-expanded="false" aria-label="' . esc_attr__( 'Toggle submenu', 'starter-theme' ) . '"><i data-lucide="chevron-down" class="size-4" aria-hidden="true"></i></button>';
		}
	}
}
