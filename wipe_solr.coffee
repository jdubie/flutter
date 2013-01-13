debug    = require 'debug'
solr     = require 'solr-client'
config   = require 'config'

debug = debug('wipe-solr')

# define callback
callback = (err, res) ->
  if err
    debug 'error', err
  else
    debug 'Solr response', res
    debug 'docs', res?.response?.docs
    process.exit()

# connect to solr
client = solr.createClient
  host: config.HOST

query = '*:*'
client.deleteByQuery(query, callback)
client.commit()
