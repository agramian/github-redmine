require 'sinatra/activerecord'
require 'optparse'
require_relative '../helpers/redmine_api'
require_relative '../models/issue'
require_relative '../models/project'
require_relative '../models/comment'

# parse command line args
options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: delete_all_redmine_issues.rb [options]'
  opts.on('-p', '--project PROJECT', 'Redmine project name') do |p|
    options[:project] = p
  end
end.parse!
raise OptionParser::MissingArgument, 'Use -h or --help to see options.' if options.empty?
# initialize classes
redmine_api = RedmineApi.new
# get project id
projects = redmine_api.get_projects()
target_project = nil
projects.each do |p|
  if p['name'] == options[:project]
    target_project = p
    break
  end
end
if !target_project
  puts 'Unabled to find project "%s"' %[options[:project]]
  exit 1
end
# get all issues for project
all_issues = redmine_api.get_issues(project_id=target_project['id'])
# delete each issue
all_issues['issues'].each do |issue|
  # delete in redmine
  redmine_api.delete_issue(id=issue['id'])
  # delete in database
  redmine_issue = Issue.where(redmine_id: issue['id']).first
  if redmine_issue.present?
    redmine_issue.destroy()
  end
end
# delete all comments associated with the project
Comment.destroy_all(github_repo_name: Project.where(redmine_project_id: target_project['id']).first.github_repo_name)
puts 'Successfully deleted all issues and comments for the "%s" project!' %[options[:project]]
exit 0
