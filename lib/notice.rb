# -*- encoding : utf-8 -*-
require 'rubygems' if RUBY_VERSION <"1.9"
require 'sinatra/base'
require 'json'

module Sinatra
    module Notice
        module Helpers
            def get_notices
                @db = settings.db
                @db.get_notices
            end
        end

        def self.registered(app)
            app.helpers Notice::Helpers

            app.post '/notice/new' do
                if authorized? and admin?
                    @db = settings.db
                    if @db.insert_notice(params) == 1
                        "true"
                    else
                        "You must fill all the data"
                    end
                end
                redirect '/#notice'
            end

            app.post '/notice/delete' do
                if authorized? and admin?
                    @db = settings.db
                    case @db.delete_notice params
                    when 1
                        "true"
                    when 0
                        "That notice doesn't exist"
                    when -1
                        "You must fill all the data"
                    end
                end
            end

            app.post '/notice/modify' do
                if authorized? and admin?
                    @db = settings.db
                    case @db.modify_notice params
                    when 1
                        redirect '/#notice'
                    when 0
                        "That notice doesn't exist"
                    when -1
                        "You must fill all the data"
                    end
                end
            end

            app.post '/notice/delete_file' do
                if authorized? and admin?
                    @db = settings.db
                    case @db.noticefile_delete params
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
