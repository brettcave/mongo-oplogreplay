require 'mongoriver'
require 'mongo'

module Oplogreplayer
  class Mongobridge < Mongoriver::AbstractOutlet

    def initialize(config)
      # set up filters and destination stuff from config.
    end

    def update_optime(timestamp)
      # track what's been written with this - write optime to the fs, perhaps periodically.
    end

    def insert(db_name, collection_name, document)
      # do insert if it matches filter
    end
    def remove(db_name,collection_name)

    end
    def update(db_name, collection_name,selector,update)
    end


    def create_index(db_name, collection_name, index_key, options)
    end
    def drop_index(db_name, collection_name, index_name)

    end

    def create_collection(db_name, collection_name,  options)

    end
    def drop_collection(db_name, collection_name)

    end

    def rename_collection(db_name, old_collection_name, new_collection_name)

    end

    def drop_database(db_name)

    end
  end
end