require 'thor'
require 'oplogreplayer'

module Oplogreplayer
  class CLI < Thor
    desc "mongo2mongo", "Replays the oplog from 1 mongo replica set to another instance or RS."
    option :config, :type => :string, :required => true, :aliases => "-c", :desc => "The configuration for oplog source"
    option :timestamp, :type => :numeric, :aliases => "-t"
    def mongo2mongo()
        Oplogreplayer::Replayer.m2m(options)
    end

  end
end