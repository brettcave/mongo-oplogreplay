require 'mongoriver'

module Oplogreplayer
  class Stdoutbridge < Mongoriver::AbstractOutlet

    @log
    @filterDbs = nil

    def initialize()

      setupLogger

      @log.info("Stdout bridge being configured")
    end

    def update_optime(timestamp)
      @log.info("update_optime: #{timestamp}")
    end

    def insert(db_name, collection_name, document)
      # @log.info("#{db_name}.#{collection_name}.insert #{document}")
    end

    def remove(db_name,collection_name, document)
      # @log.info("")
    end

    def update(db_name, collection_name,selector,update)
      @log.info("#{db_name}.#{collection_name}.update({#{selector},{#{update}})")
    end

    def create_index(db_name, collection_name, index_key, options)
      # @log.info("")
    end

    def drop_index(db_name, collection_name, index_name)
      # @log.info("")
    end

    def create_collection(db_name, collection_name,  options)
      # @log.info("")
    end

    def drop_collection(db_name, collection_name)
      # @log.info("")
    end

    def rename_collection(db_name, old_collection_name, new_collection_name)
      # @log.info("")
    end

    def drop_database(db_name)
      # @log.info("")
    end

    private

    def setupLogger()
      @log = Log4r::Logger.new("Oplogreplay::Stdoutbridge")
      @log.outputters = Log4r::StdoutOutputter.new(STDERR)
      @log.level = Log4r::INFO
    end
  end
end