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
        end
    end
end
