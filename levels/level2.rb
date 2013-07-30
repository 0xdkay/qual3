require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'

module Sinatra
	module Level2
		def self.registered(app)
			app.get '/level2' do
				authorized!
				slim :level2
			end
		end
	end
end

