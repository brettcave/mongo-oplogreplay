require 'mongoriver'

module Oplogreplayer
  class Riveroutlet < Mongoriver::AbstractOutlet
    def insert(db_name, collection_name, document)
      puts "INSERT into " + db_name + "." + collection_name
      puts "'" + document.to_s + "'"

    end

    def update(db_name, collection_name,selector,update)
      puts "Update " + db_name + "." + collection_name
      puts "Selector: " + selector.to_s
      puts "Update: " + update.to_s
    end
  end
end