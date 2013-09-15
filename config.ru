require './webserver'
use Rack::CommonLogger
#use Rack::SSL
use Rack::Deflater
run Webserver
