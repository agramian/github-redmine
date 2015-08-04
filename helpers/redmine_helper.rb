Dir[File.dirname(__FILE__) + '/../models/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require file}

class RedmineHelper

  def initialize
    # initialize classes
    @redmine_api = RedmineApi.new
    @github_api = GitHubApi.new
  end

  def get_redmine_priority(issue)
    # get all priorities
    @priorities = Priority.all
    priority_id = nil
    @priorities.each do |priority|
      if issue['labels'].detect {|l| l['name'] == priority.github_priority_name}
        priority_id = priority.redmine_priority_id
        break
      end
    end
    return priority_id
  end

  def get_redmine_tracker(issue)
    # get all issue types
    @issue_types = IssueType.all    
    tracker_id = nil
    @issue_types.each do |issue_type|
      if issue['labels'].detect {|l| l['name'] == issue_type.github_issue_type_name}
        tracker_id = issue_type.redmine_tracker_id
        break
      end
    end
    return tracker_id
  end

  def get_redmine_status(issue)
    # get all issue statuses
    @issue_statuses = Status.all    
    # get issue status
    status_id = nil
    # first look for labels indicating status
    @issue_statuses.each do |status|
      if issue['labels'].detect {|l| l['name'] == status.github_status_name}
        status_id = status
        break
      end
    end
    if status_id.nil?
      # set to closed if state is closed
      if issue['state'] == 'closed'
        status_id = Status.where(github_status_name: 'closed').first
      # set to in progress if there is an assignee
      elsif issue['assignee']
        status_id = Status.where(github_status_name: 'In Progress').first
      else
        status_id = Status.where(github_status_name: 'open').first
      end
    end
    return status_id
  end

  def process_issue(issue, project)
    # get issue status
    status_id = get_redmine_status(issue)
    # get priority
    priority_id = get_redmine_priority(issue)
    # get tracker
    tracker_id = get_redmine_tracker(issue)
    # get assignee if any
    assignee = @redmine_api.get_users(issue['assignee'] ? issue['assignee']['login'] : ENV['DEFAULT_ASSIGNEE'])    
    # construct optional post data
    body = {
      :status_id => status_id ? status_id.redmine_status_id : nil,
      :priority_id => priority_id,
      :tracker_id => tracker_id,
      :assigned_to_id => assignee['total_count'] > 0 ? assignee['users'][0]['id'] : nil,
      :author_name => issue['user']['login']
      }.delete_if { |key, value| value.to_s.strip == '' }
    # if issue exists in database just update, otherwise create
    db_issue = Issue.where(github_id: issue['number'], github_repo_name: project.github_repo_name).first
    action = nil
    if db_issue.present?
      update_body = {
        :project_id => project.redmine_project_id,
        :subject => issue['title'],
        :description => issue['body'],
      }
      @redmine_api.update_issue(id=db_issue.redmine_id, body.merge!(update_body))
      Issue.update(db_issue.id,
                   redmine_id: db_issue.redmine_id,
                   github_id: db_issue.github_id,
                   github_repo_name: db_issue.github_repo_name,
                   status_id: status_id.id)
      action = 'updated'
    else
      new_redmine_issue = @redmine_api.create_issue(project_id=project.redmine_project_id,
                                                    subject=issue['title'],
                                                    description=issue['body'],
                                                    body)
      db_issue = Issue.create(redmine_id: new_redmine_issue['issue']['id'],
                              github_id: issue['number'],
                              github_repo_name: project.github_repo_name,
                              status_id: status_id.id)
      action = 'created'
    end
    puts 'Successfully %s Redmine issue with id %s in the "%s" project/GitHub issue number %s in the "%s" repository!' \
         %[action, db_issue.redmine_id.to_s, project.redmine_project_name, db_issue.github_id.to_s, db_issue.github_repo_name]
    handle_comments(issue['number'], project)
    return db_issue
  end

  def process_comment(comment, github_issue_number, project)
    db_issue = Issue.where(github_id: github_issue_number, github_repo_name: project.github_repo_name).first
    unless db_issue.present?
      raise Exception, 'Issue not found matching github_id=%s and github_repo_name=%s' \
                       %[github_issue_number, project.github_repo_name]
    end
    # construct commend body
    #x.gsub(/\\r\\n### Author.*/, " ")
    comment_body = {
      :notes => comment['body'],
      :author_name => comment['user']['login']
    }
    # if comment exists in database just update, otherwise create
    db_comment = Comment.where(github_comment_id: comment['id'], github_repo_name: project.github_repo_name).first
    action = nil
    if db_comment.present?
      # **** REDMINE REST API DOES NOT SUPPORT JOURNAL NOTE UPDATES
      # SO THIS IS KIND OF POINTLESS BUT HERE IN CASE THEY ADD IT LATER
      # FOR NOW SKIPPING THIS BLOCK
      action = 'skipped'
      return
      @redmine_api.update_issue(id=db_issue.redmine_id, comment_body)
      Comment.update(db_comment.id, redmine_journal_id: db_comment.redmine_journal_id, github_comment_id: db_comment.github_comment_id, github_repo_name: db_comment.github_repo_name)
      action = 'updated'
    else
      @redmine_api.update_issue(id=db_issue.redmine_id, comment_body)
      updated_issue = @redmine_api.get_issue(id=db_issue.redmine_id)
      new_journal = updated_issue['issue']['journals'].detect {|j| j['notes'] == comment['body']}
      db_comment = Comment.create(redmine_journal_id: new_journal['id'], github_comment_id: comment['id'], github_repo_name: project.github_repo_name)
      action = 'created'
    end
    puts 'Successfully Redmine journal with id %s in the "%s" project/%s GitHub comment with id %s in the "%s" repository!' \
         %[action, db_comment.redmine_journal_id.to_s, project.redmine_project_name, db_comment.github_comment_id.to_s, db_comment.github_repo_name]
  end

  def handle_comments(github_issue_number, project)
    comments = @github_api.get_comments(project.github_repo_owner, project.github_repo_name, github_issue_number)
    comments.each do |comment|
      process_comment(comment, github_issue_number, project)
    end
  end

end
