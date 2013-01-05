express = require 'express'
debug   = require 'debug'
path    = require 'path'
solr    = require 'solr-client'

debug = debug('server')

app = express()
app.use express.static path.join(__dirname, 'public')

client = solr.createClient
  host: '192.168.144.1'
client.autoCommit = true

app.get '/companys', (req, res) ->
  query = req.query.q
  debug 'query', query

  # DixMax query
  solrQuery = client.createQuery()
    .q(query)
    .dismax()
    #.qf({title_t : 0.2 , description_t : 3.3})
    #.mm(2)
    #.start(0)
    #.rows(10);
  client.search solrQuery, (err, solrRes) ->
    if err
      console.log(err)
    else
      res.json(companys: solrRes.response.docs)

app.listen(8001)
