# -*- encoding : utf-8 -*-
$:.unshift(".")
require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra'
require 'slim'
require 'yaml'

require 'libs'

class Webserver < Sinatra::Base
    register Sinatra::SessionAuth
    configure do
        config = YAML.load_file("config.yml")
        config.each do |key, val|
            set key, val
        end
        set :db, DB.new(settings.dbname)
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
        if authorized?
            Pony.mail(
                :to => settings.email,
                :from => params[:email],
                :subject => "#{settings.name} - #{params[:subject]}",
                :body => params[:message]+"\n\nby #{params[:name]}")
        end
        redirect '/'
    end

    get '/*' do
        "page not found"
    end
end
