import 'bulma';
import * as Rails from 'rails-ujs'
const Turbolinks = require('turbolinks')

Rails.start()
Turbolinks.start()

// window.onload = () => {
//
// }

require.context('../images', true)
require('../stylesheets/application.scss')



// document.addEventListener('turbolinks:load', () => {

  // Get all "navbar-burger" elements
  const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);

  // Check if there are any navbar burgers
  if ($navbarBurgers.length > 0) {

    // Add a click event on each of them
    $navbarBurgers.forEach( el => {
      el.addEventListener('click', () => {

        // Get the target from the "data-target" attribute
        const target = el.dataset.target;
        const $target = document.getElementById(target);

        if ($target != null) {
          // Toggle the "is-active" class on both the "navbar-burger" and the "navbar-menu"
          el.classList.toggle('is-active');
          $target.classList.toggle('is-active');
        }

      });
    });
  }

// });
