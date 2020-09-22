import 'bootstrap';
import * as Rails from 'rails-ujs'
const Turbolinks = require('turbolinks')

Rails.start()
Turbolinks.start()

// window.onload = () => {
//
// }

require.context('../images', true)
require('../stylesheets/old/application.scss')
