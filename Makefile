load-solr:
	NODE_PATH=. \
		DEBUG=load,company \
		coffee load_solr.coffee

load-mongo:
	NODE_PATH=. \
		DEBUG=load,company \
		coffee load_mongo.coffee

.PHONY: load
