mongoose = require 'mongoose'
debug    = require 'debug'

debug = debug('company')

schema = mongoose.Schema
  permalink: type: String, unique: true
  tags: [String]

schema.post 'init', (doc) ->
  process.exit()
  debug('%s has been initialized from the db', doc._id)

module.exports = mongoose.model('Company', schema)
