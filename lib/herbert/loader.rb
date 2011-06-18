require 'logger'
require 'mongo'
require 'memcache'
require 'sinatra/base'
require 'kwalify'
require 'active_support'

module Herbert
  ::Logger.class_eval do
		# prefix all Herbert's log with [Herbert]
    [:fatal, :error, :warn, :info, :debug].each do |type|
      name = "h_" + type.to_s
      define_method name do |message|
        send(type, "[Herbert] " + message)
      end
    end
  end

  # Plug it in, the monkey style :]
  module ::Kernel
    @@logger = Logger.new(STDOUT)
    def log
      @@logger
    end
  end
	
  module Loader
    $HERBERT_PATH = File.dirname(__FILE__)
    log.h_info("Here comes Herbert. He's a berserker!")
    # because order matters
    %w{Utils Jsonify Configurator Error Services Ajaxify AppLogger Log Resource}.each {|file|
      require $HERBERT_PATH + "/#{file}.rb"
    }

    def self.registered(app)
      # Set some default
      # TODO to external file?
      app.set :log_requests, :db
      app.enable :append_log_id # If logs go to Mongo, IDs will be appended to responses
      ## register the ;debug flag patch first to enable proper logging
      app.register Herbert::Configurator::Prepatch
      # the logger
      log.level = app.development? ? Logger::DEBUG : Logger::INFO
      # the extensions
      app.register Herbert::Configurator
      app.register Herbert::Configurator::Helpers
      app.helpers Herbert::Configurator::Helpers
      app.register Herbert::Error
      app.helpers Herbert::Error::Helpers
      app.register Sinatra::Jsonify
      app.register Sinatra::Database
      app.helpers Sinatra::Database
      app.register Sinatra::Cache
      app.helpers Sinatra::Cache
      app.register Sinatra::Validation::Extension
      app.helpers Sinatra::Validation::Helpers
      app.register Herbert::Ajaxify
      app.helpers Sinatra::Log
      app.register Sinatra::Log::Extension
			app.register Herbert::ResourceLoader
    end
  end
end