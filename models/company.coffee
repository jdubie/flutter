mongoose = require 'mongoose'
debug    = require 'debug'
_        = require 'underscore'

debug = debug('company')

schema = mongoose.Schema
  permalink: type: String, unique: true
  tags: [String]
  name: String
  number_of_employees: Number
  overview: String
  category_code: String
  funding_rounds: [{
    round_code: String
    raised_amount: Number
    raised_currency_code: String
    funded_year: Number
    funded_month: Number
    funded_day: Number
  }]
  founded_year: Number
  founded_month: Number
  founded_day: Number
  image:
    available_sizes: []

schema.virtual('id').get () ->
  @permalink

schema.virtual('small_image_s').get () ->
  @image?.available_sizes?[0]?[1]

schema.virtual('category').get () ->
  @category_code

schema.virtual('cat').get () ->
  @tags

schema.virtual('overview_s').get () ->
  @overview

getMonthSinceRaise = (year, month) ->
  curYear = (new Date()).getFullYear()
  curMonth = (new Date()).getMonth() + 1
  (curYear - year)*12 + (curMonth - month)

schema.virtual('funding').get () ->
  result =
    amount_raised_d     : null
    months_since_raise_i: null

  rounds    = @funding_rounds
  numRounds = rounds.length
  for i in [numRounds...0]
    round = rounds[i-1]
    amount_raised = round.raised_amount
    funded_month  = round.funded_month
    funded_year   = round.funded_year
    if amount_raised? and funded_month? and funded_year?
      months_since_raise = getMonthSinceRaise(funded_year, funded_month)
      result.amount_raised_d = amount_raised
      result.months_since_raise_i = months_since_raise
      break
  result

schema.methods.toSolr = () ->
  ob = {
    @small_image_s
    @id
    @name
    @cat
    @category
    founded_year_i: @founded_year
    description: @overview
    number_of_employees_i: @number_of_employees
  }
  _.extend ob, @funding

schema.set('toJSON', virtuals: true)

module.exports = mongoose.model('Company', schema)
