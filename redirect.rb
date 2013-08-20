require 'sinatra'

set :server, "thin"
set :bind, "0.0.0.0"
set :port, 12313
get '/*' do
    redirect "https://#{env['SERVER_NAME']}:12312"
end



