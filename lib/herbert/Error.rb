# coding: utf-8

require File.dirname(__FILE__) + '/ApplicationError.rb'

module Herbert
  module Error
    # Inclusion hook
    def self.registered(app)
      # Disable HTML errors and preliminary reporting
      log.h_warn("Herbert is running in debugging mode - exceptions will be visualized") if app.debug?
      app.set :raise_errors, false
      app.set :show_exceptions, false
      app.set :dump_errors, app.debug?
      # Add a new error state handler which produces
      # compact JSON error reports (handled by #Sinatra::Jsonify)
      app.error do
        err = request.env['sinatra.error']
        if err.class == ApplicationError then
          log.h_debug("Caught manageable error")
          response.status = err.http_code
          body = {
            :error => {
              :code => err.code,
              :message => err.message
            }
          }
          # Add backtrace, Kwalify validation report and other info if
          # running in development mode
          if (settings.development? || settings.test?) then
            log.h_debug("Adding stacktrace and report to the error")
            body[:error][:stacktrace] = err.backtrace.join("\n")
            body[:error][:info] = (err.errors || [])
          end
          response.body = body
        else
        # If the exception is not manageable, bust it
          log.h_error("A non-managed error occured! Backtrace: #{err.to_s + err.backtrace.join("\n")}")
          response.status = 500
          response.body = (settings.development? || settings.test?) ? err.to_s : nil
        end
      end

      #Ummm, nasty.... FIXME
      app.not_found do
        content_type 'application/json', :charset => 'utf-8'
        {:error => {
          :code => 1003,
          :message => "Not found"
        }}
      end
    end

    module Helpers
      # Request-context helper of error states
      def error(code = 1020, http_code = nil, errors = nil)
        raise Herbert::Error::ApplicationError.new(code, http_code, errors)
      end
    end
  end
end