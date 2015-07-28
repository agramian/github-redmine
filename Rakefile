require 'dotenv'
Dotenv.load
require './app'
require 'sinatra/activerecord/rake'
require 'rake/testtask'

task :sync_redmine_to_github, [:projects]  do |t, args|
  if !args[:projects]
    raise Exception, 'Projects arg is required. Takes a comma-separated list of Redmine project names or "ALL". ' \
                     'Usage: "rake sync_redmine_to_github[\'PROJECT1;PROJECT2\']" OR "rake sync_redmine_to_github[\'ALL\']"'
  end
  projects_split = args[:projects].split(/;/).map(&:strip)
  if projects_split.count == 1 && projects_split[0].upcase == 'ALL'
    ruby './tasks/sync_redmine_to_github.rb'
  else
    ruby './tasks/sync_redmine_to_github.rb -p "%s"' %[projects_split.join(',')]
  end
end

task :delete_all_redmine_issues, [:project]  do |t, args|
  if !args[:project]
    raise Exception, 'Project arg is required. Usage: "rake delete_all_redmine_issues[\'PROJECT\']"'
  end
  ruby './tasks/delete_all_redmine_issues.rb -p "%s"' %[args[:project]]
end

Rake::TestTask.new do |t|
  t.libs.push 'test'
  t.pattern = 'test/**/*test*.rb'
  t.warning = true
  t.verbose = true
end
