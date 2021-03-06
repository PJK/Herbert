require 'sinatra/base'
require 'active_support'

#
# TODO: FIXME this is ugly, as it's a duplicate of herbert/Error.rb
# By default, if there was an error in Herbert, Sinatra would crash without
# catching the error and Rack would respond with empty 200 response afterwards.
# This emulates somewhat consistent behaviour and encapsulation.
#
class Sinatra::Base
	def call(env)
		begin
			dup.call!(env)
		rescue => e
			res = [500,{},[]]
			if (ENV['HERBERT_DEBUG'].to_i==1) || (ENV['RACK_ENV'] =~ /debug/) then
				res[1] = {"Content-Type" => "application/json;charset=utf-8"}
				res[2] = ActiveSupport::JSON.encode({
						:error => {
							:code => 1,
							:message => e.to_s,
							:backtrace => e.backtrace
						}
				
					})
			end
			res
		end
	end
end

require 'herbert/loader'
