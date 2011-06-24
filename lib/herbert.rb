require 'sinatra/base'
require 'yajl'
class Sinatra::Base
	def call(env)
		begin
			call!(env)
		rescue => e
			[500, 
				{"Content-Type" => "application/json;charset=utf-8"},
				Yajl::Encoder.encode({
					:error => {
						:code => 1,
						:message => e,
						:backtrace => e.backtrace
					}
				
				})
			]
		end
	end
end

require 'herbert/loader'
