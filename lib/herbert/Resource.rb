module Herbert
  # This class allows you to organize code by REST resources.
	# Any class that subclasses Herbert::Resource is automatically "merged" 
	# into the application. Resource name will be derived from the class name.
	# 
	# For instance,
	#   class Messages < Herbert::Resource
  #     get '/' do
  #    	  "here's a message for you!"
  #     end
	#   end
	# will respond to 
	#   GET /messages/
	# 
	
  class Resource
    def self.new
      raise StandardError.new('You are not allowed to instantize this class directly')
    end
		
		# Translates Sintra DSL calls
    def self.inherited(subclass)
      %w{get post put delete}.each do |verb|
        subclass.define_singleton_method verb.to_sym  do |route, &block|
          app.send verb.to_sym, "/#{subclass.to_s.downcase}#{route}", &block
        end
      end
    end
  end

	# Loads all Herbert resources
  module ResourceLoader
    def self.registered(app)
			# Inject refence to the app into Resource
      Resource.class_eval do
				define_singleton_method :app do
					app
				end
			end
			
			# And load all resource definitions
      path = File.join(app.settings.root, 'Resources')
      Dir.new(path).each do |file|
        next if %{. ..}.include? file
        require File.join(path,file)
      end
    end
  end
end