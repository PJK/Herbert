module Sinatra
  module Database
    def self.registered(app)
      app.set :mongo_connection, Mongo::Connection.new(app.settings.db_settings[:host],
      app.settings.db_settings[:porty],
      app.settings.db_settings[:options])
      log.h_debug("Connected to MongoDB #{app.settings.mongo_connection}")
      app.set :mongo_db, app.settings.mongo_connection.db(app.settings.db_settings[:db_name])
    end

    def db
      settings.mongo_db
    end

  end

  module Cache
    def self.registered(app)
      servers = []
      app.settings.cache[:servers].each {|c|
        servers << (c[:host] + ':' + (c[:port] || 11211).to_s)
      }
      app.set :cache, MemCache.new(app.settings.cache[:options])
      app.settings.cache.servers = servers
      log.h_debug("Connected to Memcached #{app.settings.cache.inspect}")
    end

    def mc
      settings.cache
    end
  end

  
  module Validation    
    module Extension
      # Um, dragons... Fucking swarm... But I'll try to explain this anyway.
      # We'll scan the defined settings.validation[:path] dir for dirs. Those found dirs
      # will denote <resource>s. Then, we will scan the "resource" dirs for files.
      # These files will represent one http <verb>.yaml each. And then, we create hierchy of 
      # validation schemas following this pattern: 
      # ::setting.validation[:module]::<resource>::<verb_schema>
      # where the <verb_schema> equals <verb>.capitalize and contains parsed contents of <verb>.yaml file. 
      # Please note that I haven't used a single (.*_)eval even though I was terribly tempted.
      # And I also documented this method. I'm so awesome, considerate and drunk, am I not?
      # Uh, yea, and notice the nice cascade of 'end's on the end
      def self.registered(app)
        # Define the ::<schema_root> module
        validation_module = Kernel.const_set(app.settings.validation[:module], Module.new)
        schema_root = Dir.new(File.join(app.settings.root, app.settings.validation[:path]))
        log.h_debug("Loading validation schemas from #{schema_root.path}");
        # For each resource
        schema_root.each do |resource_dir|
          next if %w{.. .}.include? resource_dir
          resource_name = resource_dir
          resource_dir = File.join(schema_root, resource_dir)
          # Create <schema_root>::<resource> module
          validation_module.const_set(resource_name, Module.new {})
          if File.directory?(resource_dir) then
            Dir.new(resource_dir).each do |verb|
              next if %w{.. .}.include? verb
              # And create the <schema_root>::<resource>::<verb_schema> constant
              validation_module.const_get(resource_name).const_set(/(\w+)(\.yaml|\.yml)/.match(verb)[1].capitalize, YAML.load_file(File.join(resource_dir, verb)))
            end
          end
        end
      end
    end
    
    module Helpers
      # Only a few dragons here. This method validates body of the request
      # against a schema. If no schema was passed to the method, it will
      # try to find it automagically
      def validate!(schema = nil)
        schema ||= Kernel.const_get(
          settings.validation[:module]
        ).const_get(
          /^\/(.*)\//.match(request.path)[1].capitalize
        ).const_get(
          request.env['REQUEST_METHOD'].downcase.capitalize
        )
        res = Kwalify::Validator.new(schema).validate(request.body)
        res.map! { |error|
          error.to_s
        }
        error(1012, nil, res) unless res == []
      end
    end
  end

end
