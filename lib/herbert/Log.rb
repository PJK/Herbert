module Sinatra
  module Log
    def log_request
      ::Herbert::AppLogger.log(request, response) if settings.log_requests
    end

    def timer_elapsed
      return (@timer_stop.to_f - @timer_start.to_f)*100
    end

    module Extension
      def self.registered(app)
        case app.log_requests
        when :db
          provider = Herbert::LoggingProviders::MongoProvider.new(app.db)
        when :stdout
          provider = Herbert::LoggingProviders::StdoutProvider.new
        else
					provider = app.log_requests
				end
        Herbert::AppLogger.provider = provider
        # Make the app automatically inject a reference to itself into the response,
        # so Sinatra::Response::finish can manipulate it
        app.before { response.app = self; @timer_start = Time.new; }
				app.after { @timer_stop = Time.new}
			end
		end
	end
end