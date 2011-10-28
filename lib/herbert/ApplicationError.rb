module Herbert

  # Provides centralized handling of exceptions in the
  # application context
  module Error

    # Error relevant in the application context
    class ApplicationError < StandardError
      attr_reader :code, :message, :http_code, :errors

      # Code to text translation
      Translation = {
        1000 => ["Malformated JSON", 400],
        1001 => ["Non-unicode encoding",400],
        1002 => ["Non-acceptable Accept header", 406],
        1003 => ["Not found", 404],
        1010 => ["Missing request body", 400],
        1011 => ["Missign required parameter", 400],
        1012 => ["Invalid request body", 400],
        1020 => ["Unspecified error occured", 500]
      }

      def initialize(errno, http_code = nil, errors = [])
        raise ArgumentError, "Unknown error code: #{errno}" unless Translation.has_key?(errno.to_i)
        @code = errno.to_i
        @message = Translation[@code][0]
        @http_code = (http_code || Translation[@code][1])
        @errors = errors.to_a
      end

      def to_hash
        { :code => @code, :stackTrace => backtrace, :validationTrace => @errors}
      end

      # Add an error
      def self.push(code, error)
        Translation[code.to_s] = error.to_a
      end

      # Add a hash of errors
      def self.merge(errors)
        if errors.is_a? Hash then
          Translation.merge!(errors)
        else
          raise ArgumentError("Expected a hash of codes and descriptions")
        end
      end

    end
  end
end

module Sinatra
  class NotFound
		
		# Enables Sinatra built-in exceptions to be logged
    def to_hash
      {
        :code => 1003,
        :message => "Not found"
      }
    end
  end
end