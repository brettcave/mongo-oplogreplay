require 'mongoriver'
require 'mongo'
require 'oplogreplayer/mongobridge'
require 'yaml'

module Oplogreplayer
  class Replayer

    @_config = {}
    attr_reader :_config

    # Method for testing
    def self.read(host,port,username,password)
      mongo = Mongo::MongoClient.new(host,port)
      mongo.db("admin").authenticate(username,password)

      riverconfig = {}

      # TODO: logging
      log = Log4r::Logger.new('Stripe')
      log.outputters = Log4r::StdoutOutputter.new(STDERR)
      log.level = Log4r::INFO
      tailer = Mongoriver::Tailer.new([mongo], :existing)
      bridge = Oplogreplayer::Mongobridge.new(riverconfig)
      stream = Mongoriver::Stream.new(tailer,bridge)
      stream.run_forever()

    end

    def self.m2m(config)

      self.parseConfig(@_config, config)

      sourceConfig = @_config["source"]

      connect_uri = "mongodb://"
      connect_uri += "#{sourceConfig["username"]}:#{sourceConfig["password"]}"
      connect_uri += "@#{sourceConfig["host"]}"
      connect_uri += "/#{sourceConfig["initialDb"]}"
      connect_uri += "?replicaSet=#{sourceConfig["replicaSet"]}"
      #puts "Connecting to #{connect_uri}"
      rsClient = Mongo::MongoReplicaSetClient.from_uri(connect_uri)

      rsClient.db("foo").collection("bar").find.each do |doc|
        puts "foo.bar: #{doc.inspect}"
      end

      tailer = Mongoriver::Tailer.new([rsClient], :existing)
      bridge = Oplogreplayer::Mongobridge.new(@_config["dest"])
      stream = Mongoriver::Stream.new(tailer, bridge)

      if @_config["resume"]
        # TODO: determine timestamp and pass as parameter
        stream.run_forever()
      else
        stream.run_forever()
      end


      # TODO: if username & pass is set.
      # rsClient.db("admin").authenticate(sourceConfig[:username], sourceConfig[:password])

      # If resume, then need to get the last replayed timestamp
      # parse configs
      # set up source connection
      # set up destination connection
      # run forever!! *evil laugh* - if resume, then use timestamp here.
    end




    def self.parseConfig(target, configFile)
      if ! ::File.exists?(configFile)
        raise NoConfigFileError, "Config file not found: #{configFile}"
      end

      conf = YAML::load_file(configFile)
      target.merge! conf
    end

  end

end