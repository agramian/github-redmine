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
    # first look for labels indicating status
    issue_statuses.each do |status|
      if issue['labels'].detect {|l| l['name'] == status.github_status_name }
        status_id = status.redmine_status_id
        break
      end
    end
    if status_id.nil?
      # set to closed if state is closed
      if issue['state'] == 'closed'
        status_id = Status.where(github_status_name: 'closed').first.redmine_status_id
      # set to in progress if there is an assignee
      elsif issue['assignee']
        status_id = Status.where(github_status_name: 'In Progress').first.redmine_status_id
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
      :assigned_to_id => user['total_count'] > 0 ? user['users'][0]['id'] : nil,
      :author_name => issue['user']['login']
      }.delete_if { |key, value| value.to_s.strip == '' }
    # if issue exists in database just update, otherwise create
    db_issue = Issue.where(github_id: issue['number'], github_repo_name: p.github_repo_name).first
    action = nil
    if db_issue.present?
      update_body = {
        :project_id => p.redmine_project_id,
        :subject => issue['title'],
        :description => issue['body'],
      }
      redmine_api.update_issue(id=db_issue.redmine_id, body.merge!(update_body))
      Issue.update(db_issue.id,
                   redmine_id: db_issue.redmine_id,
                   github_id: db_issue.github_id,
                   github_repo_name: db_issue.github_repo_name,
                   status_id: status_id)
      action = 'updated'
    else
      new_redmine_issue = redmine_api.create_issue(project_id=p.redmine_project_id,
                                                   subject=issue['title'],
                                                   description=issue['body'],
                                                   body)
      db_issue = Issue.create(redmine_id: new_redmine_issue['issue']['id'],
                              github_id: issue['number'],
                              github_repo_name: p.github_repo_name,
                              status_id: status_id)
      action = 'created'
    end
    puts 'Successfully %s GitHub issue number %s in the "%s" repository/Redmine issue with id %s in the "%s" project!' \
         %[action, db_issue.github_id.to_s, db_issue.github_repo_name, db_issue.redmine_id.to_s, p.redmine_project_name]
    # get all comments for the github issue for the repository if any
    if issue['comments'] > 0
      comments = github_api.get_comments(p.github_repo_owner, p.github_repo_name, db_issue.github_id)
      # create redmine notes for each github comment
      comments.each do |comment|
        # construct commend body
        comment_body = {
          :notes => comment['body'],
          :author_name => comment['user']['login']
        }
        # if comment exists in database just update, otherwise create
        db_comment = Comment.where(github_comment_id: comment['id'], github_repo_name: p.github_repo_name).first
        action = nil
        if db_comment.present?
          # **** REDMINE REST API DOES NOT SUPPORT JOURNAL NOTE UPDATES
          # SO THIS IS KIND OF POINTLESS BUT HERE IN CASE THEY ADD IT LATER
          # FOR NOW SKIPPING THIS BLOCK
          action = 'skipped'
          next
          redmine_api.update_issue(id=db_issue.redmine_id, comment_body)
          Comment.update(db_comment.id, redmine_journal_id: db_comment.redmine_journal_id, github_comment_id: db_comment.github_comment_id, github_repo_name: db_comment.github_repo_name)
          action = 'updated'
        else
          redmine_api.update_issue(id=db_issue.redmine_id, comment_body)
          updated_issue = redmine_api.get_issue(id=db_issue.redmine_id)
          new_journal = updated_issue['issue']['journals'].detect {|j| j['notes'] == comment['body']}
          db_comment = Comment.create(redmine_journal_id: new_journal['id'], github_comment_id: comment['id'], github_repo_name: p.github_repo_name)
          action = 'created'
        end
        puts 'Successfully %s GitHub comment with id %s in the "%s" repository/Redmine journal with id %s in the "%s" project!' \
             %[action, db_comment.github_comment_id.to_s, db_comment.github_repo_name, db_comment.redmine_journal_id.to_s, p.redmine_project_name]
      end
    end
  end
  puts 'Successfully synced all issues from the "%s" GitHub repository with the "%s" Redmine project!' %[p.github_repo_name, p.redmine_project_name]                           
end
exit 0
