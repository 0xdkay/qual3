$:.unshift(".")
require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra'
require 'slim'

#custom
require 'levels'
require 'test'
require 'auth'

class Webserver < Sinatra::Base
	register Sinatra::Example
	register Sinatra::SessionAuth
	register Sinatra::Level1
	register Sinatra::Level2

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
	set :public_folder, File.dirname(__FILE__) + '/html'

	get '/' do 
		slim :index
	end

	get '/*' do
		"page not found"
	end
end
