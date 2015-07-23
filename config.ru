require './app'
require 'dotenv'
Dotenv.load

configure :production do
  set :bind, '0.0.0.0'
end

configure :production, :development do
  set :bind, '0.0.0.0'
  run Sinatra::Application
end
