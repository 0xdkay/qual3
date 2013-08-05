require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'

module Sinatra
    module SessionAuth
        module Helpers
            def authorized?
                session[:id]
            end

            def authorized!
                redirect '/login' unless authorized?
            end

            def logout!
                session[:id] = nil
            end
        end

        def self.registered(app)
            app.helpers SessionAuth::Helpers

            app.get '/logout' do
                session[:id] = nil
                redirect '/'
            end

            app.get '/login' do
                redirect '/'  if authorized?
            end

            app.post '/login' do
                data = {}
                data[:id] = params[:id]
                data[:pw] = params[:pw]
                if @db.check_login data
                    session[:id] = params[:id]
                    "true"
                else
                    "wrong"
                end
            end
        end
    end
end
