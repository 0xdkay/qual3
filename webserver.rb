# -*- encoding : utf-8 -*-
$:.unshift(".")
require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra'
require 'slim'
require 'coffee_script'

#custom
require 'libs'

class Webserver < Sinatra::Base
    register Sinatra::SessionAuth

    configure do
        set :key, File.read("register_key").chomp
        set :db, DB.new(Dir.glob("*.db")[0])
        set :sessions, true
        set :show_exceptions, false
        set :public_folder, File.dirname(__FILE__) + '/public'
    end
  #set :static, true
=begin
    set :logging, true
    set :dump_errors, false
    set :some_custom_option, false
=end

    get '/' do 
        slim :index
    end

    get '/chal' do
        slim :index
    end

    post '/email' do
        "Email posted"
    end

    get '/*' do
        "page not found"
    end
end
