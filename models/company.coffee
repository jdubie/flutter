mongoose = require 'mongoose'
debug    = require 'debug'
_        = require 'underscore'

debug = debug('company')

schema = mongoose.Schema
  permalink: type: String, unique: true
  tags: [String]
  name: String
  overview: String
  funding_rounds: [{
    round_code: String
    raised_amount: Number
    raised_currency_code: String
    funded_year: Number
    funded_month: Number
    funded_day: Number
  }]

schema.virtual('id').get () ->
  @permalink

schema.virtual('cat').get () ->
  @tags
schema.virtual('overview_s').get () ->
  @overview

schema.virtual('funding').get () ->
  result = {}
  result.funding_amount_ls = @funding_rounds.map (round) ->
    round.raised_amount
  result.funding_date_dts = @funding_rounds.map (round) ->
    fundDate = new Date(round.funded_year, round.funded_day, round.funded_day)
    fundDate.toISOString()
  result

schema.methods.toSolr = () ->
  _.extend {@id, @name, @cat, description: @overview}, @funding

schema.set('toJSON', virtuals: true)

module.exports = mongoose.model('Company', schema)
