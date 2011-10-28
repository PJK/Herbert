module Herbert
	# When extended, it virtually "merges" the overriding class into the app.
	# 
	#  class Messages
	#   get '/'
	#   end
	#  end
	# will enable your app to respond to
	#  GET /messages/
  class Resource
		
		# Instantiating this class is forbidden
    def self.new
      raise StandardError.new('You are not allowed to instantiate this class directly')
    end
		
		# Translates Sinatra DSL calls
    def self.inherited(subclass)
      %w{get post put delete}.each do |verb|
        subclass.define_singleton_method verb.to_sym  do |route, &block|
          app.send verb.to_sym, "/#{subclass.to_s.downcase}#{route}", &block
        end
      end
    end
  end

	# Loads all Herbert's resources
  module ResourceLoader
		
		# Loads all application resources
    def self.registered(app)
			# Inject reference to the app into Resource
      Resource.class_eval do
				define_singleton_method :app do
					app
				end
			end			
			
			# And load all resources' definitions
      path = File.join(app.settings.root, 'Resources')
      Dir.new(path).each do |file|
        next if %{. ..}.include? file
        require File.join(path,file)
      end
    end
  end
end