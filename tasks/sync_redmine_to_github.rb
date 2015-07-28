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
github_api = GitHubApi.new
redmine_api = RedmineApi.new
# get all projects either via command line or activerecord
projects = options[:projects] ? options[:projects] : Project.find(:all)
# get all priorities
priorities = Priority.find(:all)
# get all issue statuses
issue_statuses = Status.find(:all)
# get all issue types
issue_types = IssueType.find(:all)
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
    # get assignee if any
    user = redmine_api.get_users(issue['assignee'] ? issue['assignee']['login'] : ENV['DEFAULT_ASSIGNEE'])
    # get issue status
    status_id = nil
    issue_statuses.each do |status|
      if issue['labels'].detect {|l| l['name'] == status.github_status_name }
        status_id = status.redmine_status_id
        break
      end
    end
    if status_id.nil?
      status = issue_statuses.detect {|s| s.github_status_name == issue['state']}
      if status
        status_id = status.redmine_status_id
      end
    end
    # get priority
    priority_id = nil
    priorities.each do |priority|
      if issue['labels'].detect {|l| l['name'] == priority.github_priority_name }
        priority_id = priority.redmine_priority_id
        break
      end
    end
    # get tracker
    tracker_id = nil
    issue_types.each do |issue_type|
      if issue['labels'].detect {|l| l['name'] == issue_type.github_issue_type_name }
        tracker_id = issue_type.redmine_tracker_id
        break
      end
    end   
    # construct optional post data
    body = {
      :status_id => status_id,
      :priority_id => priority_id,
      :tracker_id => tracker_id,
      :assigned_to_id => user['total_count'] ? user['users'][0]['id'] : nil
      }.delete_if { |key, value| value.to_s.strip == '' }
    # if issue exists in database just update, otherwise create
    db_issue = Issue.where(github_id: issue['number'], github_project_name: p.github_repo_name).first
    action = nil
    if db_issue.present?
      update_body = {
        :project_id => p.redmine_project_id,
        :subject => issue['title'],
        :description => issue['body'],
      }
      redmine_api.update_issue(id=db_issue.redmine_id, body.merge!(update_body))
      Issue.update(db_issue.id, redmine_id: db_issue.redmine_id, github_id: db_issue.github_id, github_project_name: db_issue.github_project_name)
      action = 'updated'
    else
      new_redmine_issue = redmine_api.create_issue(project_id=p.redmine_project_id,
                                                   subject=issue['title'],
                                                   description=issue['body'],
                                                   body)
      db_issue = Issue.create(redmine_id: new_redmine_issue['issue']['id'], github_id: issue['number'], github_project_name: p.github_repo_name)
      action = 'created'
    end
    puts 'Successfully %s GitHub issue number %s in the "%s" repository/Redmine issue with id %s in the "%s" project!' \
         %[action, db_issue.github_id.to_s, db_issue.github_project_name, db_issue.redmine_id.to_s, p.redmine_project_name]
  end
  puts 'Successfully synced all issues from the "%s" GitHub repository with the "%s" Redmine project!' %[p.github_repo_name, p.redmine_project_name]                           
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
exit 0
=end