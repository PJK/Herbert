module Herbert
  # Full-fledged request & response logger with
  # several storage providers (console, mongo, cache)
  class AppLogger
    def self.provider
      @@provider
    end

    def self.provider=(prov)
      @@provider = prov
    end

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

      # Extract tha headerz
      request.env.keys.each do |key|
        if key =~ /^HTTP_/ then
          log['request']['headers'][key.gsub(/^HTTP_/,'')] = request.env[key]
        end
      end
      # do not log bodies from GET/DELETE/HEAD
      log["request"].delete("body") if %{GET DELETE HEAD}.include?(log["request"]["method"])
      # If an error occured, add it
      log["response"]["error"] = request.env['sinatra.error'].to_hash if request.env['sinatra.error']
      id = @@provider.save(log)
      response['X-RequestId'] = id.to_s if @@provider.respond_to?(:id) && response.app.settings.append_log_id
    end
  end
	
	module LoggingProviders
		class StdoutProvider
			def initialize
				require 'pp'
			end

			def save(log)
				pp log
			end
		end

		class MongoProvider

			Collection = 'logs'
    
			def initialize(db)
				@db = db
			end

			def save(log)
				@db[Collection].save(log)
			end
    
			def id
				true
			end
		end
  end
end