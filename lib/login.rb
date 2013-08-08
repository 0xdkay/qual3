require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'
require 'pony'

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

            def token_link(type, token)
                "http://#{env['HTTP_HOST']}/#{type}/#{token}"
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
                @db = DB.new $db_name
                params[:ip] = request.ip
                case @db.check_login params
                when 1
                    session[:id] = params[:id]
                    "true"
                when 0
                    "ID - PASSWORD combination doesn't exist"
                when -1
                    "You must fill all the data"
                end
            end

            app.post '/register' do
                if params[:pw] != params[:pw_confirm]
                    "You must confirm your password correctly"
                else
                    if params[:key] == $key
                        @db = DB.new $db_name
                        params[:ip] = request.ip
                        case @db.insert_user params
                        when 1
                            "true"
                        when 0
                            "ID or Email already exsits"
                        when -1
                        "You must fill all the data"
                        end
                    else
                        "Registeration key doesn't match"
                    end
                end
            end

            app.post '/recovery' do
                @db = DB.new $db_name
                token = @db.check_mail params
                case token
                when 0
                    "Email doesn't exist"
                when -1
                    "You must fill all the data"
                else
                    Pony.mail(
                        :to => params[:mail],
                        :from => "no-reply@#{env['SERVER_NAME']}", 
                        :subject => "password recovery",
                        :body => "Hi, below link is for your password reset.\n #{token_link('reset', token)}")
                    "true"
                end
            end

            app.get '/reset/:token/?' do
                @db = DB.new $db_name
                redirect '/' if authorized?

                if params[:token].nil? || params[:token].empty?
                    redirect '/'
                end

                if @db.check_token(params) == 1
                    session[:token] = params[:token]
                    redirect '/#reset'
                else
                    redirect '/'
                end
            end

            app.post '/reset' do
                if params[:pw] == params[:pw_confirm] and session[:token]
                    @db = DB.new $db_name
                    params[:token] = session[:token]
                    case @db.reset_password params
                    when -1
                        "You must fill all the data"
                    when 1
                        session[:token] = nil
                        "true"
                    end
                end
            end
        end
    end
end
