#################################################
## @author github.com/aotimme
## @url    https://raw.github.com/aotimme/crunchyco/develop/scripts/extractCompanies.coffee
#################################################

fs       = require 'fs'
path     = require 'path'
debug    = require 'debug'
async    = require 'async'
mongoose = require 'mongoose'
expat    = require 'node-expat'
S        = require 'string'
Lazy     = require 'lazy'
Company  = require 'models/company'

CRUNCHBASE_FILE = path.join('data', 'cbase.ndj')
#CRUNCHBASE_FILE = path.join('data', 'small.ndj')
debug = debug('load_mongo')

# connect to db
mongoose.connect('mongodb://localhost/cbase')

lineNum = 0
numCompanies = 0
companies = []
oldestYear = 2013

parseHTML = (overview) ->
  p = expat.createParser()
  textChunks = []
  p.on 'text', (text) -> textChunks.push(text)
  p.parse(overview)
  textChunks.join('')

createCompany = (company, callback) ->
  #debug 'creating', company.permalink

  # tags
  if company.tag_list?.length > 0
    tags = company.tag_list?.split(', ')
    tags = tags.map (tag) -> tag.trim()
    company.tags = tags

  # overview 
  if company.overview
    company.overview = parseHTML(company.overview)

  company = new Company(company)
  company.save(callback)

stream = fs.createReadStream(CRUNCHBASE_FILE)
stream.on 'end', ->
  debug 'PARSED'
  Company.remove {}, ->
    async.map companies, createCompany, (err) ->
      if err
        debug 'error', err
      else
        debug "success: #{numCompanies} companies"
        debug "oldest: #{oldestYear}"
      mongoose.connection.close()

companyHasRequiredFields = (company) ->
  fields = [
    'permalink'
    'number_of_employees'
    'founded_year'
  ]
  for field in fields
    if not company[field]?
      return false
  true

roundHasRequiredFields = (round) ->
  fields = [
    'raised_amount'
    'funded_year'
    'funded_month'
    'funded_day'
  ]
  for field in fields
    if not round[field]?
      return false
  true

new Lazy(stream)
  .lines
  .forEach (line) ->
    lineNum++
    try
      companyJSON = JSON.parse(line)
    catch e
      debug "#{lineNum}: BAD"

    if companyJSON?
      if companyHasRequiredFields(companyJSON)
        if companyJSON.founded_year < oldestYear
          oldestYear = companyJSON.founded_year
        if companyJSON.funding_rounds?.length > 0
          rounds = companyJSON.funding_rounds
          round  = rounds[rounds.length - 1]
          if roundHasRequiredFields(round)
            numCompanies++
            companies.push companyJSON
