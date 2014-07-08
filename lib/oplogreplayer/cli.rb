require 'thor'
require 'oplogreplayer'

module Oplogreplayer
  class CLI < Thor
    desc "replay HOST PORT USERNAME PASSWORD", "The source to connect to."
    def replay(host,port,username,pass)
      Oplogreplayer::Replayer.replay(host,port,username,pass)
    end

  end
end