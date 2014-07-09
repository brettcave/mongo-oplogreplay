require 'thor'
require 'oplogreplayer'

module Oplogreplayer
  class CLI < Thor
    desc "read HOST PORT USERNAME PASSWORD", "The source to connect to."
    def replay(host,port,username,pass)
      Oplogreplayer::Replayer.read(host,port,username,pass)
    end

    desc "mongo2mongo", "Replays the oplog from 1 mongo replica set to another instance or RS."
    option :config, :type => :string, :required => true, :aliases => "-c", :desc => "The configuration for oplog source"
    # option :resume, :type => :boolean, :default => true, :aliases => :r, :desc => "Resumes from the last recorded timestamp (overrides what's in config"
    option :timestamp, :type =>
    def mongo2mongo()
      Oplogreplayer::Replayer.m2m(options[:config])
    end

  end
end