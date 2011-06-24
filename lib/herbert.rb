require 'sinatra/base'
require 'yajl'
class Sinatra::Base
	def call(env)
		begin
			call!(env)
		rescue => e
			res = [500,{},[]]
			if (ENV['HERBERT_DEBUG'].to_i==1) || (ENV['RACK_ENV'] =~ /debug/) then
				res[1] = {"Content-Type" => "application/json;charset=utf-8"}
				res[2] = Yajl::Encoder.encode({
						:error => {
							:code => 1,
							:message => e,
							:backtrace => e.backtrace
						}
				
					})
			end
			res
		end
	end
end

require 'herbert/loader'
