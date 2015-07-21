require_relative '../helpers/github_api'
require_relative '../helpers/redmine_api'
require_relative '../config/mapping'

# initialize classes
github_api = GitHubApi.new
redmine_api = RedmineApi.new
mapping = Mapping.new

# for each project
# create a redmine issue for each github issue 
mapping.project.each do |redmine_project, github_project|
  # get all github issues for the repository
  issues = github_api.get_issues(github_project['owner'], github_project['project'])
  # find the redmine project id
  projects = redmine_api.get_projects()
  target_project = nil
  projects.each do |p|
    if p['name'] == redmine_project
      target_project = p
    end
  end
  
  puts target_project
end
