module Herbert
  module Configurator
		
		# Sets up the environment so we can set up Herbert
    module Prepatch
			
			#
      def self.registered(app)
        # Enable envs such as development;debug, where debug is herberts debug flag
        if ENV['RACK_ENV'] === nil then
          app.set :environment, :test
          ENV['HERBERT_DEBUG'] = '1'
        end
        if ! app.test? then
          env = ENV['RACK_ENV'].split(';')
          ENV['RACK_ENV'], ENV['HERBERT_DEBUG'] = (env[0].empty? ? 'development' :  env[0]), (env[1] == 'debug' ? 1:0).to_s
          app.set :environment, ENV['RACK_ENV'].downcase.to_sym
        end
      end
    end
    
    module Helpers
      def staging?
        ENV['RACK_ENV'] == 'staging'
      end

      def development?
        ENV['RACK_ENV'] == 'development' || (ENV['RACK_ENV']===nil)
      end

      def debug?
        ENV['HERBERT_DEBUG'] == '1'
      end
    end

    def self.registered(app)
      app.enable :logging if app.development?
      #Assume loading by rackup...
      puts app.settings.root
      app.settings.root ||= File.join(Dir.getwd, 'lib')
      path = File.join(app.settings.root, 'config')
      # Load and evaluate common.rb and appropriate settings
      ['common.rb', app.environment.to_s + '.rb'].each do |file|
        cpath = File.join(path, file)
        if File.exists?(cpath) then
          # Ummm, I'm sorry?
          app.instance_eval(IO.read(cpath))
          log.h_debug("Applying #{cpath} onto the application")
        else
          log.h_warn("Configuration file #{cpath} not found")
        end
      end
      # So, we have all our settings... Please note that configure
      # block inside an App can overwrite our settings, but Herbert's
      # services are being created right now, so they only take in account
      # previous declarations
    end

  end
end