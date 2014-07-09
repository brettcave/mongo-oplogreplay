require 'mongoriver'

module Oplogreplayer
  class Mongobridge < Mongoriver::AbstractOutlet

    # include Oplogreplayer::Logging

    @_mongoClient
    @log

    def initialize(config)

      setupLogger

      # set up filters and destination stuff from config.
      # puts "Initializing bridge with config #{config.inspect}"
      connect_uri = "mongodb://"
      connect_uri += "#{config["username"]}:#{config["password"]}"
      connect_uri += "@#{config["host"]}"
      connect_uri += "/#{config["initialDb"]}"
      connect_uri += "?replicaSet=#{sourceConfig["replicaSet"]}" unless config["mode"] == "single"

      if config["mode"] == "single"
        @log.info("Setting up single target")
        @_mongoClient = Mongo::MongoClient.from_uri(connect_uri)
      else
        @log.info("Setting up RS target")
        @_mongoClient = Mongo::MongoReplicaSetClient.from_uri(connect_uri)
      end
    end

    def getOplogTimestamp()
      findStamp = @_mongoClient.db("local").collection("oplog.tracker").find_one()
      if findStamp
        @log.info("Stamp found: #{findStamp.inspect}")
        findStamp["timestamp"]
      else
        @log.info("No stamp found")
        nil
      end
    end

    def update_optime(timestamp)
      # track what's been written with this - write optime to the fs, perhaps periodically.
      @log.info("Optime: #{timestamp}")
      @_mongoClient.db("local").collection("oplog.tracker").find_and_modify({:query => {}, :update => {'timestamp' => timestamp}, :upsert => true})
    end

    def insert(db_name, collection_name, document)
      if (db_name == "foo")
        @log.info("Found an insert: #{db_name}.#{collection_name} => #{document.inspect}")
      end
    end
    def remove(db_name,collection_name, document)

    end
    def update(db_name, collection_name,selector,update)
      if (db_name == "foo")
        @log.info("Found an update: #{db_name}.#{collection_name} => #{selector} => #{update}")
      end
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

    def setupLogger()
      @log = Log4r::Logger.new("Oplogreplay::Mongobridge")
      @log.outputters = Log4r::StdoutOutputter.new(STDERR)
      @log.level = Log4r::INFO
    end
  end
end