$:.unshift(".")
require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra'
require 'slim'
require 'coffee_script'

#custom
require 'pages'

class Webserver < Sinatra::Base
	register Sinatra::SessionAuth

  #set :static, true
	set :sessions, true
	set :username, "test"
	set :password, "secret"

=begin
	set :logging, true
	set :dump_errors, false
	set :some_custom_option, false
=end
	set :show_exceptions, false
	set :public_folder, File.dirname(__FILE__) + '/public'

	get '/' do 
		slim :index
	end

	get '/home' do
		slim :index
	end

	get '/chal' do
		slim :index
	end

	get '/email' do
		slim :index
	end

	post '/email' do
		"Email posted"
	end

	get '/*' do
		"page not found"
	end
end
