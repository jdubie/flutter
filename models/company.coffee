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
  image:
    available_sizes: []

schema.virtual('id').get () ->
  @permalink

schema.virtual('small_image_s').get () ->
  @image?.available_sizes?[0]?[1]

schema.virtual('cat').get () ->
  @tags

schema.virtual('overview_s').get () ->
  @overview

getMonthSinceRaise = (year, month) ->
  curYear = (new Date()).getFullYear()
  curMonth = (new Date()).getFullMonth() + 1
  (curYear - year)*12 + (curMonth - month)

schema.virtual('funding').get () ->
  result = {}
  amounts_raised = @funding_rounds.map (round) ->
    round.raised_amount
  fundingDates = @funding_rounds.map (round) ->
    months_since_raise = getMonthSinceRaise(round.funded_year, round.funded_month)

  result.amount_raised_l      = _.last(amounts_raised)
  result.months_since_raise_i = _.last(fundingDates)
  result

schema.methods.toSolr = () ->
  _.extend {@small_image_s, @id, @name, @cat, description: @overview}, @funding

schema.set('toJSON', virtuals: true)

module.exports = mongoose.model('Company', schema)
