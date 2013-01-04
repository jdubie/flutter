#################################################
## @author github.com/aotimme
## @url    https://raw.github.com/aotimme/crunchyco/develop/scripts/extractCompanies.coffee
#################################################

fs       = require 'fs'
path     = require 'path'
debug    = require 'debug'
async    = require 'async'
mongoose = require 'mongoose'
Lazy     = require 'lazy'
Company  = require 'models/company'

CRUNCHBASE_FILE = path.join('data', 'cbase.ndj')
debug = debug('load')

# connect to db
mongoose.connect('mongodb://localhost/cbase')

lineNum = 0
companies = []

createCompany = (company, callback) ->
  debug 'creating', company.permalink
  tags = company.tag_list?.split(', ')
  tags = tags.map (tag) -> tag.trim()
  debug 'tags', tags
  company.tags = tags
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
        debug 'success'
        process.exit()

PERMALINKS = [
  'orchestra'
  'pulse'
  'google'
  'microsoft'
]

#getCompany = (companyJSON, callback) ->
#  Company.findOne permalink: companyJSON.permalink, (err, company) ->
#    debug 'getCompany'
#    process.exit()
#    if company is null
#      company = new Company(companyJSON)
#    callback(err, company)

new Lazy(stream)
  .lines
  .forEach (line) ->
    lineNum++
    try
      companyJSON = JSON.parse(line)
    catch e
      debug "#{lineNum}: BAD"

    if companyJSON?.permalink in PERMALINKS
      companies.push companyJSON

      #getCompany companyJSON, (err, company) ->
      #  if err
      #    debug 'error', err
      #  debug 'company', company
        #company.save()
