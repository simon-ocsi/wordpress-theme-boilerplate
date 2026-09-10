import '../css/tailwind.css'
import '../scss/app.scss'
import { createIcons, ChevronDown, Menu, X } from 'lucide'

const initIcons = () => {
  createIcons({
    icons: { ChevronDown, Menu, X },
  })
}

const initNavigation = () => {
  const menuButton = document.querySelector('[data-menu-toggle]')
  const menu = document.querySelector('[data-mobile-menu]')
  const openIcon = document.querySelector('[data-menu-icon-open]')
  const closeIcon = document.querySelector('[data-menu-icon-close]')

  if (menuButton && menu) {
    menuButton.addEventListener('click', () => {
      const isOpen = menuButton.getAttribute('aria-expanded') === 'true'
      menuButton.setAttribute('aria-expanded', String(!isOpen))
      menu.classList.toggle('hidden', isOpen)
      openIcon?.classList.toggle('hidden', !isOpen)
      closeIcon?.classList.toggle('hidden', isOpen)
    })
  }

  document.querySelectorAll('[data-dropdown-toggle]').forEach((button) => {
    button.addEventListener('click', () => {
      const submenu = button.nextElementSibling
      if (!submenu) return

      const isOpen = button.getAttribute('aria-expanded') === 'true'
      button.setAttribute('aria-expanded', String(!isOpen))
      submenu.classList.toggle('hidden', isOpen)
    })
  })
}

document.addEventListener('DOMContentLoaded', () => {
  initIcons()
  initNavigation()
})
