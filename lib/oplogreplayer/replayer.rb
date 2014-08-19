require 'mongoriver'
require 'oplogreplayer/mongobridge'
require 'oplogreplayer/stdoutbridge'
require 'yaml'

module Oplogreplayer
  class Replayer

    @_config = {}

    def self.m2m(options)

      config = options[:config]
      timestamp = options[:timestamp]

      log = Log4r::Logger.new('Oplogreplayer::Replayer')
      log.outputters = Log4r::StdoutOutputter.new(STDERR)
      log.level = Log4r::INFO
      self.parseConfig(@_config, config)

      sourceConfig = @_config["source"]

      connect_uri = "mongodb://"
      connect_uri += "#{sourceConfig["username"]}:#{sourceConfig["password"]}@" if sourceConfig["username"] and sourceConfig["password"]
      connect_uri += "#{sourceConfig["host"]}"
      connect_uri += "?replicaSet=#{sourceConfig["replicaSet"]}"

      log.info("Setting up client for source")
      rsClient = Mongo::MongoReplicaSetClient.from_uri(connect_uri)

      log.info("Configuring tailer")
      tailer = Mongoriver::Tailer.new([rsClient], :existing)

      log.info("Creating mongo2mongo bridge")
      bridge = Oplogreplayer::Mongobridge.new(@_config["dest"])

      log.info("Creating a stream between tailer and bridge")
      stream = Mongoriver::Stream.new(tailer, bridge)

      # If a timestamp is supplied as an argument, override.
      if timestamp
        log.info("Replaying. Timestamp provided, overriding and starting at #{timestamp}")
        stream.run_forever(timestamp)
      elsif @_config["resume"]
        log.info("Replaying. No timestamp provided but resume is enabled, will resume based on target's last timestamp")
        # otherwise, try and resume.
        # We need persistence of the oplog. Not sure whether to use local fs or destination mongo
        # destination mongo seems better suited though. I'm going to use the local db for now.

        # If an exception is raised, then oplogtimestamp+1 is returned and the problematic op will not be executred
        # TODO: provide a mechanism to resume using the previous timestamp (as apposed to ts+1) for reruns from raised exceptions.
        stream.run_forever(bridge.getOplogTimestamp)
      else
        # No timestamp and no resume.... we're doing a full replay.
        log.info("Replaying. No resume and no timestamp - full oplog replay.")
        stream.run_forever()
      end
    end

    def self.stdout(options)

      config = options[:config]
      timestamp = options[:timestamp]

      log = Log4r::Logger.new('Oplogreplayer::Replayer')
      log.outputters = Log4r::StdoutOutputter.new(STDERR)
      log.level = Log4r::INFO
      self.parseConfig(@_config, config)

      sourceConfig = @_config["source"]

      connect_uri = "mongodb://"
      connect_uri += "#{sourceConfig["username"]}:#{sourceConfig["password"]}@" if sourceConfig["username"] and sourceConfig["password"]
      connect_uri += "#{sourceConfig["host"]}"
      connect_uri += "?replicaSet=#{sourceConfig["replicaSet"]}"

      log.info("Setting up client for source")
      rsClient = Mongo::MongoReplicaSetClient.from_uri(connect_uri)

      log.info("Configuring tailer")
      tailer = Mongoriver::Tailer.new([rsClient], :existing)

      log.info("Creating stdout bridge")
      bridge = Oplogreplayer::Stdoutbridge.new()

      log.info("Creating a stream between tailer and bridge")
      stream = Mongoriver::Stream.new(tailer, bridge)

      # If a timestamp is supplied as an argument, override.
      if timestamp
        log.info("Replaying. Timestamp provided, overriding and starting at #{timestamp}")
        stream.run_forever(timestamp)
      else
        # No timestamp and no resume.... we're doing a full replay.
        log.info("Replaying. No resume and no timestamp - full oplog replay.")
        stream.run_forever()
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