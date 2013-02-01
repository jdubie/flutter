debug = require 'debug'
solr  = require 'solr-client'
config = require 'config'
async = require 'async'

debug = debug 'update-doc'

# parameters (example)
name = "PhotoMania"
fieldChanges =
  months_since_raise_i: 24

# connect to solr
if config.HOST is 'localhost'
  client = solr.createClient()
else
  client = solr.createClient
    host: config.HOST

client.autoCommit = true

query = "name:#{name}"
solrQuery = client.createQuery().q(query)
doc = null
async.waterfall [
  (next) ->
    client.search solrQuery, next
  (res, next) ->
    doc = res.response.docs[0]
    debug 'got doc:', doc.name
    client.deleteByID doc.id, next
  (res, next) ->
    debug 'updating doc:', doc
    for key, value in fieldChanges
      doc[key] = value
    delete doc._version_
    client.add doc, next
  (res, next) ->
    debug 'added back'
    client.search solrQuery, next
], (err, res) ->
  if err
    debug 'ERROR!', err
  else
    doc = res.response.docs[0]
    debug 'doc updated:', doc
