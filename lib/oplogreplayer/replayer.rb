require 'mongoriver'
require 'mongo'
require 'oplogreplayer/riveroutlet'

module Oplogreplayer
  class Replayer
    def self.replay(host,port,username,password)
      mongo = Mongo::MongoClient.new(host,port)
      mongo.db("admin").authenticate(username,password)


      tailer = Mongoriver::Tailer.new([mongo], :existing)
      outlet = Oplogreplayer::Riveroutlet.new()
      stream = Mongoriver::Stream.new(tailer,outlet)
      stream.run_forever()

    end
  end
end