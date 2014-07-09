module Oplogreplayer
  module Logging
    def log
      @@logger ||= Log4r::Logger.new("Oplogreplayer")
    end
  end

  class NoConfigFileError < StandardError; end

end