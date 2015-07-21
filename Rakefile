require "./app"
require "sinatra/activerecord/rake"
require './env' if File.exists?('env.rb')

task :sync_redmine_to_github do
  ruby "./setup/sync_redmine_to_github.rb"
end