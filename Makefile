load-solr:
	NODE_PATH=. \
		DEBUG=* \
		coffee load_solr.coffee

load-mongo:
	NODE_PATH=. \
		DEBUG=load_mongo,company \
		coffee load_mongo.coffee

wipe-solr:
	NODE_PATH=. \
		DEBUG=wipe-solr \
		coffee wipe_solr.coffee

.PHONY: load
