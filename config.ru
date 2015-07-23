# configure port
#\ -p 9494

require './app'
require 'dotenv'
Dotenv.load
require './config/environments'

configure :production do
  set :bind, '0.0.0.0'
end

run Sinatra::Application
