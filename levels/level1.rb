require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'
require 'auth'
require 'rack'

module Sinatra
	module Level1
		def self.registered(app)
			app.get '/level1' do
				authorized!
				session!

				if session[:level1]
				else
				end
				session[:level1] = [get, cnt]
				@value = Random.rand(10**10)
				slim :level1
			end
		end
	end
end

