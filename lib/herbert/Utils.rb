module Herbert
  module Utils
    # Assert v<major>.<minor>.<etc> tags
    def self.version
      version = `git describe --long`.strip
      version[0] = '' if version[0] == 'v'
      version
    end
    
    module Helpers
      def version
        Utils.version
      end
      
      def nonce(length = 8)
        ActiveSupport::SecureRandom.hex(length)
      end
      
      def db_id(source)
        BSON::ObjectId.from_string(source.to_s)
      end
    end
  end
end