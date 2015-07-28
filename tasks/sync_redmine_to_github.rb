require 'sinatra/activerecord'
require 'optparse'
require_relative '../models/issue'
require_relative '../helpers/github_api'
require_relative '../helpers/redmine_api'

# parse command line args
options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: delete_all_redmine_issues.rb [options]'
  opts.on('-p', '--projects PROJECT1,PROJECT 2', 'Comma separated Redmine project names.') do |p|
    options[:projects] = p.split(/,/).map(&:strip)
  end
end.parse!
# initialize classes
github_api = GitHubApi.new
redmine_api = RedmineApi.new
puts redmine_api.get_trackers()
exit
=begin
# for each project
# create a redmine issue for each github issue 
mapping.project.each do |redmine_project, github_project|
  # continue if projects argument passed and not in projects
  if options[:projects] and !options[:projects].include? redmine_project
    next
  end
  # find the redmine project id
  projects = redmine_api.get_projects()
  target_project = nil
  projects.each do |p|
    if p['name'] == redmine_project
      target_project = p
    end
  end
  # get all github issues for the repository
  issues = github_api.get_issues(github_project['owner'], github_project['project'])
  # create redmine issues
  issues.each do |issue|
    user = redmine_api.get_users(issue['assignee']['login'])
    labels = issue['labels']
    body = {
          'project_id' => target_project['id'],
          'subject' => issue['title'],
          'description' => issue['body'],
          'status_id' => options[:status_id] || nil,
          'priority_id' => options[:priority_id] || nil,
          'assigned_to_id' => user['total_count'] ? user['users'][0]['id'] : nil
          }.delete_if { |key, value| value.to_s.strip == '' }
    puts body
    break
    redmine_api.create_issue(project_id=target_project['id'],
                             subject='test create issue via api',
                             description='qwerqwerqwer')
    break
  end
  puts 'Successfully synced all issues from the "%s" GitHub repository with the "" Redmine project!' %[github_project, redmine_project]                           
end

exit 0

#Issue.create(redmine_id: 1, github_id: 2)
=begin

  all_issues = redmine_api.get_issues(project_id=target_project['id'])
  #print all_issues
  print redmine_api.get_issue(id=all_issues['issues'][0]['id'])
  exit
  #print redmine_api.delete_issue(id=all_issues['issues'][1]['id'])
  print redmine_api.update_issue(id=all_issues['issues'][2]['id'],
                                 subject='test change title via api 2',
                                 description='test change description via api 2',
                                 :notes => 'test comment via api, using **options parameter')
  exit

#print redmine_api.get_user(86)
#exit



exit

#puts slack_api.post_message('@abtin', message='test')
#exit

url = 'https://github.guidebook.com/github-enterprise-assets/0000/0040/0000/2189/abe553ec-344f-11e5-8765-6d098227f291.gif'
File.extname(url)

content = github_api.get_attachement_content(url)

#print redmine_api.upload_attachment(content)

exit
#File.extname(file)
filepath = '/Users/agramian/Documents/Guidebook-repositories/github-redmine/test/data/attachments/test.png'
File.open(filepath, 'wb') { |f|
  f.write(content)
}
exit

filepath = '/Users/agramian/Documents/Guidebook-repositories/github-redmine/test/data/attachments/guidebook-icon.png'
content = nil
File.open(filepath, 'rb') { |f|
  content = f.read
}
puts content


print redmine_api.get_users('abtin')
exit
=end

