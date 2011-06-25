class True
  def as_json
    return 1
  end
end

class BSON::ObjectId
  def as_json(*a)
    to_s
  end
end

module Sinatra

  # Makes JSON the default DDL of HTTP communication
  module Jsonify
    # Sinatra inclusion hook
    def self.registered(app)
      app.before do
        log.h_debug("Adding proper content-type and charset")
        content_type 'application/json', :charset => 'utf-8'
      end
    end

    class Sinatra::Request

      @is_json = false
      # Encapsulates Rack::Request.body in order to remove #IO.String
      # and therefore to enable repeated reads
      def body_raw
        @body_raw ||= body(true).read
        @body_raw
      end

      def ensure_encoded(strict = true)
        if !@is_json then
          begin
            @body_decoded ||= ActiveSupport::JSON.decode(body_raw)
            @is_json = true;
          rescue StandardError
            @is_json = false;
            raise ::Herbert::Error::ApplicationError.new(1000) if strict
          end
        end
      end

      # Overrides Rack::Request.body, returns native #Hash
      # Preserves access to underlying @env['rack.input'] #IO.String
      def body(rack = false)
        if rack then
					super()
        else
          ensure_encoded
					@body_decoded
        end
      end

      def json?
        ensure_encoded(false)
        @is_json
      end
    end

    class Sinatra::Response
      # Reference to application instance that created this response
      attr_accessor :app
      
      # Automatically encode body to JSON, but only as long as
      # the content-type remained set to app/json
      def finish
        @app.log_request
        if json?
          log.h_debug("Serializing response into JSON")
          @body = [ActiveSupport::JSON.encode(@body)]
        end
        super
      end
      
      def json?
        @header['Content-type'] === 'application/json;charset=utf-8'
      end
    end
  end
end