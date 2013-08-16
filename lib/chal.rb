# -*- encoding : utf-8 -*-
require 'rubygems' if RUBY_VERSION <"1.9"
require 'sinatra/base'
require 'json'

module Sinatra
    module Challenge
        module Helpers
            def get_probs
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
                probs.safe_transpose
            end
        end

        def self.registered(app)
            app.helpers Challenge::Helpers

            app.post '/chal/new' do
                if authorized? and admin?
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
                    if prob == -1
                        "You must fill all the data"
                    else
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

            app.post '/chal/delete' do
                if authorized? and admin?
                    @db = settings.db
                    case @db.delete_prob params
                    when 1
                        "true"
                    when 0
                        "That problem doesn't exist"
                    when -1
                        "You must fill all the data"
                    end
                end
            end

            app.post '/chal/modify' do
                if authorized? and admin?
                    @db = settings.db
                    case @db.modify_prob params
                    when 1
                        redirect '/#chal'
                    when 0
                        "Problem doesn't exist"
                    when -1
                        "You must fill all the data"
                    end
                end
            end

            app.get '/chal/modify/:pno' do
                if authorized? and admin?
                    @db = settings.db
                    prob = @db.show_prob params
                    if prob == -1
                        "You must fill all the data"
                    else
                        {
                            :pno => prob[0],
                            :category => prob[1],
                            :title => prob[2],
                            :author => prob[3],
                            :body => prob[4],
                            :auth => prob[5],
                            :score => prob[6],
                            :file => prob[7],
                            :date => prob[8],
                            :ldate => prob[9]
                        }.to_json
                    end
                end
            end

            app.post '/chal/delete_file' do
                if authorized? and admin?
                    @db = settings.db
                    case @db.file_delete params
                    when 1
                        "true"
                    when 0
                        "No file exists"
                    when -1
                        "You must fill all the data"
                    end
                end
            end
        end
    end
end

