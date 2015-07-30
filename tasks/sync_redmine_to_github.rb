require 'sinatra/activerecord'
require 'optparse'
Dir[File.dirname(__FILE__) + '/../models/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/../helpers/*.rb'].each {|file| require file }

# parse command line args
options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: sync_redmine_to_github.rb [options]'
  opts.on('-p', '--projects PROJECT1,PROJECT 2', 'Comma separated Redmine project names.') do |p|
    options[:projects] = p.split(/,/).map(&:strip)
  end
end.parse!
# initialize classes
github_api = GitHubApi.new
redmine_api = RedmineApi.new
redmine_helper = RedmineHelper.new
# get all projects either via command line or activerecord
projects = options[:projects] ? options[:projects] : Project.find(:all)
# for each project
# create a redmine issue for each github issue
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
  # get all github issues for the repository
  issues = github_api.get_issues(p.github_repo_owner, p.github_repo_name)
  # create redmine issues
  issues.each do |issue|
    # create/edit issue
    db_issue = redmine_helper.process_issue(issue, p)
    # get all comments for the github issue for the repository if any
    if issue['comments'] > 0
      comments = github_api.get_comments(p.github_repo_owner, p.github_repo_name, db_issue.github_id)
      # create redmine notes for each github comment
      comments.each do |comment|
        # create/edit comment
        redmine_helper.process_comment(comment, issue['number'], p)
      end
    end
  end
  puts 'Successfully synced all issues from the "%s" GitHub repository with the "%s" Redmine project!' %[p.github_repo_name, p.redmine_project_name]                           
end
exit 0
