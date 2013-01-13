debug    = require 'debug'
mongoose = require 'mongoose'
solr     = require 'solr-client'
config   = require 'config'
Company  = require 'models/company'

debug = debug('solr')

# connect to db
mongoose.connect('mongodb://localhost/cbase')

# define callback
callback = (err, res) ->
  if err
    debug 'error', err
  else
    debug 'Solr response', res
    debug 'docs', res?.response?.docs

# connect to solr
if config.HOST is 'localhost'
  client = solr.createClient()
else
  client = solr.createClient
    host: config.HOST

client.autoCommit = true

Company
  .find()
  .exec (err, companies) ->
    mongoose.connection.close()
    if err
      debug 'error', err
    else
      companies = companies.map (company) -> company.toSolr()
      #debug 'companies', companies

      # Add documents
      client.add(companies, callback)
