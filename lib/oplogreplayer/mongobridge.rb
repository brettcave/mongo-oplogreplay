require 'mongoriver'

module Oplogreplayer
  class Mongobridge < Mongoriver::AbstractOutlet

    @_mongoClient
    @log
    @filterDbs = nil


    def initialize(config)

      setupLogger

      @log.info("Mongo bridge being configured")

      connect_uri = "mongodb://"
      connect_uri += "#{config["username"]}:#{config["password"]}@" if config["username"] and config["password"]
      connect_uri += "#{config["host"]}"
      connect_uri += "?replicaSet=#{config["replicaSet"]}" if config["replicaSet"]

      if config["replicaSet"]
        @_mongoClient = Mongo::MongoReplicaSetClient.from_uri(connect_uri)
        @log.info("Target connection configured. Target is a replica set.")
      else
        @_mongoClient = Mongo::MongoClient.from_uri(connect_uri)
        @log.info("Target connection configured. Target is a single instance.")
      end

      if config["onlyDbs"]
        @filterDbs = config["onlyDbs"].split(",")
        @log.info("Filter Dbs has been configured: #{@filterDbs.to_s}")
      end
    end

    def getOplogTimestamp()
      begin
        findStamp = @_mongoClient.db("local").collection("oplog.tracker").find_one()
      rescue
        @log.error("Unable to get oplog timestamp from target database.")
        raise
      end
      if findStamp
        @log.debug("Stamp found: #{findStamp.inspect}")
        # We return timestamp+1 as "timestamp" was already replayed before shutdown.
        findStamp["timestamp"]+1
      else
        @log.debug("No stamp found. That should mean full replay.")
        nil
      end
    end

    # This is potentially bad - a find and update for every oplog....
    def update_optime(timestamp)
      # track what's been written with this - write optime to the fs, perhaps periodically.
      @log.debug("Optime: #{timestamp}")
      begin
        @_mongoClient.db("local").collection("oplog.tracker").update({}, {'timestamp' => timestamp}, {:upsert => true})
      rescue
        @log.error("Unable to update optime: #{timestamp}")
        raise
      end
    end

    def insert(db_name, collection_name, document)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("insert #{db_name}.#{collection_name} : #{document.inspect}")
        begin
          @_mongoClient.db(db_name).collection(collection_name).insert(document)
        rescue Exception => e
          @log.error("Unable to insert into #{db_name}.#{collection_name}: #{document}")
          raise
        end
      end
    end

    def remove(db_name,collection_name, document)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("remove #{db_name}.#{collection_name} : #{document.inspect}")
        begin
          @_mongoClient.db(db_name).collection(collection_name).remove(document)
        rescue Exception => e
          @log.error("Unable to remove from #{db_name}.#{collection_name}: #{document}")
          raise
        end
      end
    end

    def update(db_name, collection_name,selector,update)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("update #{db_name}.#{collection_name} : #{selector} : #{update}")
        begin
          @_mongoClient.db(db_name).collection(collection_name).update(selector,update)
        rescue Exception => e
          @log.error("Unable to update #{db_name}.#{collection_name}; selector: #{selector}; update: #{update}")
          raise
        end
      end
    end

    def create_index(db_name, collection_name, index_key, options)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("create_index #{db_name}.#{collection_name} : #{index_key} : #{options}")
        begin
          @_mongoClient.db(db_name).collection(collection_name).create_index(index_key,options)
        rescue Exception => e
          @log.error("Unable to create index in #{db_name}.#{collection_name}; Key: #{index.key}; Options: #{options}")
          raise
        end
      end
    end

    def drop_index(db_name, collection_name, index_name)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("drop_index #{db_name}.#{collection_name} : #{index_name}")
        begin
          @_mongoClient.db(db_name).collection(collection_name).drop_index(index_name)
        rescue Exception => e
          @log.error("Unable to drop index in #{db_name}.#{collection_name}: #{index_name}")
          raise
        end
      end
    end

    def create_collection(db_name, collection_name,  options)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("create_collection #{db_name} : #{collection_name} : #{options}")
        begin
          @_mongoClient.db(db_name).create_collection(collection_name,options)
        rescue Exception => e
          @log.error("Unable to create collection in #{db_name}; collection: #{collection_name}; Options: #{options}")
          raise
        end
      end
    end

    def drop_collection(db_name, collection_name)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("drop_collection #{db_name} : #{collection_name}")
        begin
          @_mongoClient.db(db_name).drop_collection(collection_name)
        rescue Exception => e
          @log.error("Unable to drop collection in #{db_name}; collection: #{collection_name}")
          raise
        end
      end
    end

    def rename_collection(db_name, old_collection_name, new_collection_name)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("rename_collection #{db_name} : from #{old_collection_name} to #{new_collection_name}")
        begin
          @_mongoClient.db(db_name).rename_collection(old_collection_name,new_collection_name)
        rescue Exception => e
          @log.error("Unable to rename collection in #{db_name}; from: #{old_collection_name}; new: #{new_collection_name}")
          raise
        end
      end
    end

    def drop_database(db_name)
      if @filterDbs and @filterDbs.include? db_name
        @log.debug("drop_database #{db_name}")
        begin
          @_mongoClient.drop_database(db_name)
        rescue Exception => e
          @log.error("Unable to drop database: #{db_name}")
          raise
        end
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