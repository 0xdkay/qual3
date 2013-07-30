require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'

module Sinatra
	module SessionAuth
		module Helpers
			def authorized?
				session[:id]
			end

			def authorized!
				redirect '/login' unless authorized?
			end

			def logout!
				session[:id] = nil
			end
		end

		def self.registered(app)
			app.helpers SessionAuth::Helpers

			app.get '/logout' do
				session[:id] = nil
				redirect '/'
			end

			app.get '/login' do
				redirect '/'  if authorized?
				slim :login
			end

			app.post '/login' do
				if params[:id] == options.username && params[:pw] == options.password
					session[:id] = params[:id]
					redirect '/'
				else
					session[:id] = nil
					redirect '/login'
				end
			end
		end
	end
end
