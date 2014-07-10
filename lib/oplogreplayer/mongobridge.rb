require 'mongoriver'

module Oplogreplayer
  class Mongobridge < Mongoriver::AbstractOutlet

    # include Oplogreplayer::Logging

    @_mongoClient
    @log
    @filterDbs = nil


    def initialize(config)

      setupLogger

      # set up filters and destination stuff from config.
      # puts "Initializing bridge with config #{config.inspect}"
      connect_uri = "mongodb://"
      connect_uri += "#{config["username"]}:#{config["password"]}"
      connect_uri += "@#{config["host"]}"
      connect_uri += "/#{config["initialDb"]}"
      connect_uri += "?replicaSet=#{config["replicaSet"]}" unless config["mode"] == "single"

      if config["mode"] == "single"
        @log.info("Setting up single target")
        @_mongoClient = Mongo::MongoClient.from_uri(connect_uri)
      else
        @log.info("Setting up RS target")
        @_mongoClient = Mongo::MongoReplicaSetClient.from_uri(connect_uri)
      end

      if config["onlyDbs"]
        @filterDbs = config["onlyDbs"].split(",")
        @log.info("Filter Dbs has been configured: #{@filterDbs.to_s}")
      end
    end

    def getOplogTimestamp()
      findStamp = @_mongoClient.db("local").collection("oplog.tracker").find_one()
      if findStamp
        @log.info("Stamp found: #{findStamp.inspect}")
        # We return timestamp+1 as "timestamp" was already replayed before shutdown.
        findStamp["timestamp"]+1
      else
        @log.info("No stamp found")
        nil
      end
    end

    # This is potentially bad - a find and update for every oplog....
    def update_optime(timestamp)
      # track what's been written with this - write optime to the fs, perhaps periodically.
      @log.info("Optime: #{timestamp}")
      @_mongoClient.db("local").collection("oplog.tracker").find_and_modify({:query => {}, :update => {'timestamp' => timestamp}, :upsert => true})
    end

    def insert(db_name, collection_name, document)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("insert #{db_name}.#{collection_name} : #{document.inspect}")
        @_mongoClient.db(db_name).collection(collection_name).insert(document)
      end
    end

    def remove(db_name,collection_name, document)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("remove #{db_name}.#{collection_name} : #{document.inspect}")
        @_mongoClient.db(db_name).collection(collection_name).remove(document)
      end
    end

    def update(db_name, collection_name,selector,update)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("update #{db_name}.#{collection_name} : #{selector} : #{update}")
        @_mongoClient.db(db_name).collection(collection_name).update(selector,update)
      end
    end


    def create_index(db_name, collection_name, index_key, options)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("create_index #{db_name}.#{collection_name} : #{index_key} : #{options}")
        @_mongoClient.db(db_name).collection(collection_name).create_index(index_key,options)
      end
    end

    def drop_index(db_name, collection_name, index_name)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("drop_index #{db_name}.#{collection_name} : #{index_name}")
        @_mongoClient.db(db_name).collection(collection_name).drop_index(index_name)
      end
    end

    def create_collection(db_name, collection_name,  options)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("create_collection #{db_name} : #{collection_name} : #{options}")
        @_mongoClient.db(db_name).create_collection(collection_name,options)
      end
    end
    def drop_collection(db_name, collection_name)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("drop_collection #{db_name} : #{collection_name}")
        @_mongoClient.db(db_name).drop_collection(collection_name)
      end
    end

    def rename_collection(db_name, old_collection_name, new_collection_name)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("rename_collection #{db_name} : from #{old_collection_name} to #{new_collection_name}")
        @_mongoClient.db(db_name).rename_collection(old_collection_name,new_collection_name)
      end
    end

    def drop_database(db_name)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("drop_database #{db_name}")
        @_mongoClient.drop_database(db_name)
      end
    end

    private

    def setupLogger()
      @log = Log4r::Logger.new("Oplogreplay::Mongobridge")
      @log.outputters = Log4r::StdoutOutputter.new(STDERR)
      @log.level = Log4r::INFO
    end
  end
end