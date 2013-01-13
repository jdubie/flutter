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
  {q, lower, upper} = req.query

  solrQuery = client.createQuery()
    .q(q)
    .start(0)
    .rows(10)
    .rangeFilter(field: 'funding_date_dts', start: "NOW-#{lower}YEAR", end: "NOW-#{upper}YEAR")
    .sort('score desc')

  client.search solrQuery, (err, solrRes) ->
    if err
      console.log(err)
    else
      res.json(companys: solrRes.response.docs)

app.listen(8002)
