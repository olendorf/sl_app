const { environment } = require('@rails/webpacker')



const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    'window.jQuery': 'jquery',
    Popper: ['popper.js', 'default']
  })
)

environment.config.merge(
  {
    output: {
        hashFunction: "sha256"
    }
}
)

module.exports = environment
