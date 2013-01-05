mongoose = require 'mongoose'
debug    = require 'debug'

debug = debug('company')

schema = mongoose.Schema
  permalink: type: String, unique: true
  tags: [String]
  name: String
  overview: String

schema.virtual('id').get () ->
  this.permalink

schema.virtual('cat').get () ->
  this.tags

schema.set('toJSON', virtuals: true)

module.exports = mongoose.model('Company', schema)
