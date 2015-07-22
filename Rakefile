require "./app"
require "sinatra/activerecord/rake"
require 'dotenv'
Dotenv.load

task :sync_redmine_to_github do
  ruby "./setup/sync_redmine_to_github.rb"
end