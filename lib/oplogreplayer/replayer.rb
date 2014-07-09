require 'mongoriver'
require 'oplogreplayer/mongobridge'
require 'yaml'

module Oplogreplayer
  class Replayer

    @_config = {}

    def self.m2m(config, timestamp = nil)

      log = Log4r::Logger.new('Oplogreplayer::Replayer')
      log.outputters = Log4r::StdoutOutputter.new(STDERR)
      log.level = Log4r::INFO
      self.parseConfig(@_config, config)

      sourceConfig = @_config["source"]

      connect_uri = "mongodb://"
      connect_uri += "#{sourceConfig["username"]}:#{sourceConfig["password"]}"
      connect_uri += "@#{sourceConfig["host"]}"
      connect_uri += "/#{sourceConfig["initialDb"]}"
      connect_uri += "?replicaSet=#{sourceConfig["replicaSet"]}"

      rsClient = Mongo::MongoReplicaSetClient.from_uri(connect_uri)

      tailer = Mongoriver::Tailer.new([rsClient], :existing)
      bridge = Oplogreplayer::Mongobridge.new(@_config["dest"])
      stream = Mongoriver::Stream.new(tailer, bridge)

      # If a timestamp is supplied as an argument, override.
      if timestamp
        log.info("Timestamp provided, starting at #{timestamp}")
        stream.run_forever(timestamp)
      elsif @_config["resume"]
        log.info("No timestamp provided, determining timestamp from destination")
        # otherwise, try and resume.
        # We need persistence of the oplog. Not sure whether to use local fs or destination mongo
        # destination mongo seems better suited though. I'm going to use the local db for now.
        stream.run_forever(bridge.getOplogTimestamp)
      else

      end
    end

    def self.parseConfig(target, configFile)
      if ! ::File.exists?(configFile)
        raise NoConfigFileError, "Config file not found: #{configFile}"
      end

      conf = YAML::load_file(configFile)
      target.merge! conf
    end

    def self.setupLogging()

    end

  end

end