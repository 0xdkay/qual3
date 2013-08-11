# -*- encoding : utf-8 -*-
require 'rubygems' if RUBY_VERSION <"1.9"
require 'sinatra/base'
require 'json'

module Sinatra
    module Challenge
        module Helpers
        end

        def self.registered(app)
            app.helpers Challenge::Helpers

            app.post '/chal/new' do
                if authorized? and admin?
                    if params[:file] and params[:file][:tempfile] and params[:file][:filename]
                        File.open('uploads/' + params[:category] + "/" + params[:file][:filename], "w") do |f|
                            f.write(params['file'][:tempfile].read)
                        end
                    end
                    @db = settings.db
                    if @db.insert_prob(params) == 1
                        "true"
                    else
                        "You must fill all the data"
                    end
                end
                redirect '/#chal'
            end

            app.post '/chal/show' do
                if authorized?
                    @db = settings.db
                    prob = @db.show_prob params
                    {
                        :pno => prob[0],
                        :name => prob[1][0..2].upcase + prob[6].to_s,
                        :category => prob[1],
                        :title => prob[2],
                        :author => prob[3],
                        :body => prob[4],
                        :file => prob[7],
                        :solved => prob[10]? prob[10]: 0
                    }.to_json
                end
            end

            app.post '/chal/auth' do
                if authorized?
                    params[:id] = session[:id]
                    @db = settings.db
                    case @db.check_auth params
                    when -1
                        "You must fill all the data"
                    when 2
                        "You already solved"
                    when 0
                        "Key doesn't match"
                    when 1
                        "true"
                    end
                end
            end

            app.get '/download/:category/:filename' do
                if authorized?
                    send_file "uploads/#{params[:category]}/#{params[:filename]}", 
                                        :filename => params[:filename], 
                                        :type => 'Application/octet-stream'
                end
            end
        end
    end
end

