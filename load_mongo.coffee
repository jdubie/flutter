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
debug = debug('load_mongo')

# connect to db
mongoose.connect('mongodb://localhost/cbase')

lineNum = 0
companies = []

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
        debug 'success'
      mongoose.connection.close()

new Lazy(stream)
  .lines
  .forEach (line) ->
    lineNum++
    try
      companyJSON = JSON.parse(line)
    catch e
      debug "#{lineNum}: BAD"

    if companyJSON?.permalink
      companies.push companyJSON
