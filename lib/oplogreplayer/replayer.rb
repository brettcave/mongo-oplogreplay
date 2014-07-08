require 'mongoriver'
require 'mongo'
require 'oplogreplayer/mongobridge'

module Oplogreplayer
  class Replayer
    def self.replay(host,port,username,password)
      mongo = Mongo::MongoClient.new(host,port)
      mongo.db("admin").authenticate(username,password)

      # TODO: riverconfig to be determined from a config file and/or parameters.
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
  end
end