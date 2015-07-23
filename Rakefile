require './app'
require 'dotenv'
Dotenv.load
require 'sinatra/activerecord/rake'
require 'rake/testtask'

task :sync_redmine_to_github do
  ruby "./setup/sync_redmine_to_github.rb"
end

Rake::TestTask.new do |t|
  t.libs.push 'test'
  t.pattern = 'test/**/*test*.rb'
  t.warning = true
  t.verbose = true
end