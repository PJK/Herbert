module Herbert
  # Full-fledged request & response logger with
  # several storage providers (console, mongo, cache)
  class AppLogger
		
		# Provider getter
    def self.provider
      @@provider
    end
		
		# Provider setter
    def self.provider=(prov)
      @@provider = prov
    end

		# Creates log message and passes it to storage provider
		#
		# @param [Sinatra::Request]
		# @param [Sinatra::Response]
		#
    def self.log(request, response)
      log = {
        "request"=> {
          "path"=> request.path,
          "method"=> request.request_method,
          "xhr" => request.xhr?,
          "postData"=> request.POST,
          "query"=> request.GET,
          "headers"=> {},
          "body"=> {
            "isJson"=> request.json?,
            "value"=> request.json? ? request.body : request.body_raw
          },
          "client"=> {
            "ip"=> request.ip,
            "hostname"=> request.host,
            "referer"=> request.referer
          }
        },
        "response"=> {
          "code"=> response.status,
          "headers"=> response.headers,
          "body"=> {
            "isJson"=> response.json?,
            "value"=> response.body
          },
        },
        "meta"=> {
          "dateTime"=> Time.new,
          "processingTime"=> response.app.timer_elapsed.round(3),
          "port" => request.port
        }
      }

      # Extract the headers
      request.env.keys.each do |key|
        if key =~ /^HTTP_/ then
          log['request']['headers'][key.gsub(/^HTTP_/,'')] = request.env[key]
        end
      end
      # do not log bodies from GET/DELETE/HEAD
      log["request"].delete("body") if %{GET DELETE HEAD}.include?(log["request"]["method"])
      # If an error has occurred, add it
      log["response"]["error"] = request.env['sinatra.error'].to_hash if request.env['sinatra.error']
      id = @@provider.save(log)
      response['X-RequestId'] = id.to_s if @@provider.respond_to?(:id) && response.app.settings.append_log_id
    end
  end

  # TODO move to separate file?
	module LoggingProviders
		
		# Dumps all logs to STDOUT with pretty formatting
		class StdoutProvider
			def initialize
				require 'pp'
			end

			def save(log)
				pp log
			end
		end

		# Persists logs in DB
		class MongoProvider
			Collection = 'logs' 
			def initialize(db)
				@db = db
			end

			# @param [Hash]
			def save(log)
				@db[Collection].save(log)
			end
    
			# TODO
			# "Flag" indicating that this provider returns IDs
			# 
			# @return [Boolean]
			def id
				true
			end
		end
  end
end