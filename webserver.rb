# -*- encoding : utf-8 -*-
$:.unshift(".")
require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra'
require 'slim'
require 'yaml'

require 'libs'

require 'rack/deflater'
require 'rack/ssl'
require 'thin'

class Array
    def safe_transpose
        max_size = self.map(&:size).max
        self.dup.map{|r| r << nil while r.size < max_size; r}.transpose
    end
end

class Webserver < Sinatra::Base
    register Sinatra::SessionAuth
    register Sinatra::Challenge
    register Sinatra::Notice

    configure do
        config = YAML.load_file("config.yml")
        config.each do |key, val|
            set key, val
        end
        set :db, DB.new(settings.dbname)
        set :register_key, File.read(settings.register_key_path)

        FileUtils.mkdir_p 'uploads/notices'
        settings.category.each do |v|
            FileUtils.mkdir_p 'uploads/'+v
        end
    end
  #set :static, true

    module Helpers
        def get_ranks
            @db = settings.db
            @db.get_ranks
        end

        def get_id
            session[:id]
        end

        def get_ranks_all
            @db = settings.db
            @db.get_ranks_all
        end

        def get_rank_series min
            @db = settings.db
            @db.get_rank_series min
        end
    end

    helpers Webserver::Helpers

    get '/' do 
        slim :index
    end

    get '/rank_all' do
        slim :rank_all
    end

    get '/rank/:min' do
        min = params[:min].to_i ? params[:min].to_i : 5;
        res = get_rank_series min
        if not res
            "NO"
        else
            res.to_json
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

    get '/download/:category/:filename' do
        if params[:category] == "notices" or (authorized? and settings.category.include?(params[:category]))
            send_file "uploads/#{params[:category]}/#{params[:filename]}", 
                                :filename => params[:filename], 
                                :type => 'Application/octet-stream'
        end
    end

    get '/*' do
        redirect '/'
    end

end


