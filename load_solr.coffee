debug    = require 'debug'
mongoose = require 'mongoose'
solr     = require 'solr-client'
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
client = solr.createClient
  host: '192.168.144.1'

client.autoCommit = true

Company
  .find()
  .exec (err, companies) ->
    mongoose.connection.close()
    if err
      debug 'error', err
    else
      companies = companies.map (company) -> company.toSolr()
      debug 'companies', companies

      # Add documents
      client.add(companies, callback)
