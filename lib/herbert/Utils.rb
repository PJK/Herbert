class Hash
  def delete_all(*names)
    names.each {|name| delete(name)}
    self
  end
end


module Herbert
  module Utils
    # Assert v<major>.<minor>.<etc> tags
    def self.version
      version = `git describe --long`.strip
      if $?.success?
        version[0] = '' if version[0] == 'v'
        return version
      else
        return IO.read("#{Dir.getwd}/VERSION")
      end
    end
    
    module Helpers
      def version
        Utils.version
      end
      
      Range = [('0'..'9').to_a,('a'..'z').to_a].flatten
      RangeLength = Range.length

      def nonce(length = 16)
        res = ''
        length.times  {res += Range[rand(RangeLength)]}
        res
      end

      # MongoDB IDs deserialization helper
      def db_id(source)
        BSON::ObjectId.from_string(source.to_s)
      end
    end
  end
end