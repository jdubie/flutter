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

#CRUNCHBASE_FILE = path.join('data', 'cbase_small.ndj')
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

beingCreated = 0
created = 0

callback = ->

createCompany = (line) ->

  try
    company = JSON.parse(line)
  catch e
    debug "#{lineNum}: BAD"

  if company?.permalink

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
  else
    callback()

stream = fs.createReadStream(CRUNCHBASE_FILE)
stream.on 'end', ->
  callback = ->
    debug 'success'
    mongoose.connection.close()

Company.remove {}, ->
  lazy = new Lazy(stream)
  lazy.lines
    .forEach (line) ->
      beingCreated++
      createCompany(line)

#async.map lazy, createCompany, (err) ->
#  if err
#    debug 'error', err
#  else
#    debug 'success'
#    mongoose.connection.close()
