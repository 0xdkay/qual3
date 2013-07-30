require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'

module Sinatra 
	module Example
		def self.registered(app)
			app.get '/named_via_params/:argument' do
				"
Using: '/named_via_params/:argument'<br/>
params[:argument] -> #{params[:argument]} (Try changing it)
				"
			end

			app.get '/named_via_block_parameter/:argument' do |argument|
				"
Using: '/named_via_block_parameter/:argument'<br/>
argument -> #{argument}
"
			end

			app.get '/splat/*/bar/*' do
				"
Using: '/splat/*/bar/*'<br/>
params[:splat] -> #{params[:splat].join(', ')}
"
			end

			app.get '/splat_extension/*.*' do
				"
Using: '/splat_extension/*.*'<br/>
filename -> #{params[:splat][0]}<br/>
extension -> #{params[:splat][1]}
"
			end

			app.get %r{/regexp_params_captures/([\w]+)} do
				"params[:captures].first -> '#{params[:captures].first}'"
			end

			app.get %r{/regexp_captures_via_block_parameter/([\w]+)} do |c|
				"c -> '#{c}'"
			end

		end
	end
	register Example
end
