process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')

environment.config.merge(
  {
    output: {
        hashFunction: "sha256"
    }
}
)

module.exports = environment.toWebpackConfig()
