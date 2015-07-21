require './app'

configure :production do
  set :bind, '0.0.0.0'
end

run Sinatra::Application
