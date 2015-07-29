require 'sinatra/activerecord'
require 'optparse'
Dir[File.dirname(__FILE__) + '/../models/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/../helpers/*.rb'].each {|file| require file }

# parse command line args
options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: delete_all_redmine_issues.rb [options]'
  opts.on('-p', '--projects PROJECT1,PROJECT 2', 'Comma separated Redmine project names.') do |p|
    options[:projects] = p.split(/,/).map(&:strip)
  end
end.parse!
# initialize classes
redmine_api = RedmineApi.new
# get project id
# get all projects either via command line or activerecord
projects = options[:projects] ? options[:projects] : Project.find(:all)
# for each project
# delete the associated redmine issues
projects.each do |p|
  # if arguments passed, handle differently
  if p.class == String
    name = p
    p = Project.where(redmine_project_name: p).first
    if !p
      puts 'Unabled to find project "%s"' %[name]
      exit 1
    end
  end
  # get all issues for project
  all_issues = redmine_api.get_issues(project_id=p.redmine_project_id)
  # delete each issue
  all_issues.each do |issue|
    # delete in redmine
    redmine_api.delete_issue(id=issue['id'])
    # delete in database
    redmine_issue = Issue.where(redmine_id: issue['id']).first
    if redmine_issue.present?
      redmine_issue.destroy()
    end
    puts 'deleted issue %s' %[issue['id']]
  end
  # delete all comments associated with the project
  Comment.destroy_all(github_repo_name: Project.where(redmine_project_id: p.redmine_project_id).first.github_repo_name)
  puts 'Successfully deleted all issues and comments for the "%s" Redmine project!' %[p.redmine_project_name]
end
exit 0
