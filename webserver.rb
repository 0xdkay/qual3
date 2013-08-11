# -*- encoding : utf-8 -*-
$:.unshift(".")
require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra'
require 'slim'
require 'yaml'

require 'libs'

require 'rack/deflater'
require 'webrick'
require 'webrick/https'
require 'openssl'

class Array
    def safe_transpose
        max_size = self.map(&:size).max
        self.dup.map{|r| r << nil while r.size < max_size; r}.transpose
    end
end

class Webserver < Sinatra::Base
    use Rack::Deflater
    register Sinatra::SessionAuth
    register Sinatra::Challenge
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
        if authorized?
            @db = settings.db
            prob_list = @db.get_probs
            probs = Array.new(settings.category.size){Array.new}
            settings.category.each.with_index do |category, index|
                prob_list.each do |prob|
                    if prob[1] == category
                        if probs[index]
                            probs[index] += [prob]
                        else
                            probs[index] = [prob]
                        end
                    end
                end
            end
            probs = probs.safe_transpose
            slim :index, :locals => {:probs => probs}
        else
            slim :index
        end
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
        redirect '/'
    end
end

