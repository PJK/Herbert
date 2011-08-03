module Herbert
	
	# Enhances AJAJ/AJAX support
  module Ajaxify
		
		# Headers to send with each request
    Headers = {
      'Access-Control-Allow-Methods' => %w{POST GET PUT DELETE OPTIONS},
      'Access-Control-Allow-Headers' => %w{Content-Type X-Requested-With},
      'Access-Control-Allow-Origin' => %w{*},
      'Access-Control-Expose-Header' => %w{Content-Type Content-Length X-Build},
      'X-Build' => [Herbert::Utils.version]
    }

		# * Loads config/headers.rb
		# 
		# * Enables header processing
		# 
		# * Registers CORS proxy for external services
		# 
		# @param [Sinatra::Base descendant]
		#
    def self.registered(app)
      # Heeeaderzz!!! Gimme heaaaderzzz!!!
      path = File.join(app.settings.root, 'config','headers.rb')
      if File.exists?(path) then
        log.h_debug("Loading additional headers from #{path}")
        custom = eval(File.open(path).read)
        custom.each {|name, value|
          value = [value] unless value.is_a?(Array)
          Headers[name] = (Headers[name] || []) | value
        }
      else
        log.h_info("File #{path} doesn't exists; no additional headers loaded")
      end

      app.before do
				# Add the headers to the response
        Headers.each {|name, value|
          value = [value] unless value.is_a?(Array)
          value.map! {|val|
            (val.is_a?(Proc) ? val.call : val).to_s
          }
          response[name] = value.join(', ')
        }
      end

      # Proxy for not CORS enables services such as 
      # Google Maps
      # /proxy/url?=
      app.get '/proxy/' do
				url = URI.parse(URI.encode(params[:url]))
				res = Net::HTTP.start(url.host, 80) {|http|
					http.get(url.path + '?' + url.query)
				}
				response['content-type'] = res['content-type']
				res.body
			end
    end
	end
end