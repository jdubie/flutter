express = require 'express'
debug   = require 'debug'
path    = require 'path'
solr    = require 'solr-client'
config  = require 'config'

debug = debug('server')

app = express()
app.use express.static path.join(__dirname, 'public')

if config.HOST is 'localhost'
  client = solr.createClient()
else
  client = solr.createClient
    host: config.HOST
client.autoCommit = true

app.get '/companies', (req, res) ->
  {q, max, category, startYear, endYear} = req.query
  max ?= 20
  category ?= "*"
  q ?= "*"
  q += " " if q
  q += "category:#{category}"

  solrQuery = client.createQuery()
    .q(q)
    .start(0)
    .rows(max)
    .rangeFilter(field: 'founded_year_i', start: startYear, end: endYear)
    #.rangeFilter(field: 'funding_date_dts', start: "NOW-#{lower}YEAR", end: "NOW-#{upper}YEAR")
    .sort('score desc')

  client.search solrQuery, (err, solrRes) ->
    if err
      console.log(err)
    else
      res.json(companies: solrRes.response.docs)

app.listen(8002)
