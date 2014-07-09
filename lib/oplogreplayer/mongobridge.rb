require 'mongoriver'
require 'mongo'

module Oplogreplayer
  class Mongobridge < Mongoriver::AbstractOutlet

    @_mongoClient
    attr_reader :_mongoClient

    def initialize(config)
      # set up filters and destination stuff from config.
      # puts "Initializing bridge with config #{config.inspect}"
      connect_uri = "mongodb://"
      connect_uri += "#{config["username"]}:#{config["password"]}"
      connect_uri += "@#{config["host"]}"
      connect_uri += "/#{config["initialDb"]}"
      connect_uri += "?replicaSet=#{sourceConfig["replicaSet"]}" unless config["mode"] == "single"


      if config["mode"] == "single"
        puts "Setting up single target"
        @_mongoClient = Mongo::MongoClient.from_uri(connect_uri)
      else
        puts "Setting up RS target"
        @_mongoClient = Mongo::MongoReplicaSetClient.from_uri(connect_uri)
      end
    end

    def update_optime(timestamp)
      # track what's been written with this - write optime to the fs, perhaps periodically.

    end

    def insert(db_name, collection_name, document)
      # do insert if it matches filter
      #db = rsClient.db("foo")
      #coll = db.collection("bar")
      #coll.find.each { |doc|
      #  puts "DOC: #{doc.inspect}"
      #}
    end
    def remove(db_name,collection_name, document)

    end
    def update(db_name, collection_name,selector,update)
    end


    def create_index(db_name, collection_name, index_key, options)
    end
    def drop_index(db_name, collection_name, index_name)

    end

    def create_collection(db_name, collection_name,  options)

    end
    def drop_collection(db_name, collection_name)

    end

    def rename_collection(db_name, old_collection_name, new_collection_name)

    end

    def drop_database(db_name)

    end
  end
end