Dir[File.dirname(__FILE__) + '/../models/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require file}

class GitHubHelper

  def initialize
    # initialize classes
    @github_api = GitHubApi.new
    @redmine_api = RedmineApi.new
  end

  def handle_comments(issue)
    project = Project.where(:redmine_project_id => issue['project']['id']).first
    # get redmine issue to check attachments later
    redmine_issue = @redmine_api.get_issue(id=issue['id'])
    db_issue = Issue.where(redmine_id: issue['id']).first
    github_issue = @github_api.get_issue(project.github_repo_owner, project.github_repo_name, db_issue.github_id)
    journals = redmine_issue['issue']['journals']
    journals.each do |journal|
      if journal['notes'].empty?
        action = 'skipped'
        next
      end
      # if comment exists in database just update, otherwise create
      db_comment = Comment.where(redmine_journal_id: journal['id']).first
      action = nil
      # construct comment body
      comment_body = journal['notes']
      # add author
=begin
      comment_body += '
### Author
%s' %[journal['author']['login']]
=end
      # see if there are any new attachments
      new_attachments = [] 
      # check if attachments have changed or are not included in issue body and add
      current_issue_body = github_issue['body']
      github_attachments = current_issue_body.scan(/\!\[.*\]\(.*\)/)
      current_issue_comments = @github_api.get_comments(project.github_repo_owner, project.github_repo_name, github_issue['number'])
      current_issue_comments.each do |comment|
        github_attachments += comment['body'].scan(/\!\[.*\]\(.*\)/)
      end
      redmine_issue['issue']['attachments'].each do |redmine_attachment|
        unless github_attachments.detect {|g| g.include? redmine_attachment['content_url']}
            new_attachments.push(redmine_attachment['content_url'])
        end
      end
      # process comment      
      if db_comment.present? && new_attachments.empty?
        # edit comment
        action = 'edited'
        @github_api.edit_comment(project.github_repo_owner,
                                 project.github_repo_name,
                                 db_comment.github_comment_id,
                                 comment_body)      
        Comment.update(db_comment.id,
                       redmine_journal_id: journal['id'],
                       github_comment_id: db_comment.github_comment_id,
                       github_repo_name: project.github_repo_name)        
      else
        unless new_attachments.empty?
          # contruct attachment links to put in comment
          comment_body += '
### Attachments'
          new_attachments.each do |attachment|
            comment_body += '
![](%s)' %[attachment]
          end     
        end
        # create comment
        action = 'created'
        new_github_comment = @github_api.create_comment(project.github_repo_owner,
                                                        project.github_repo_name,
                                                        github_issue['number'],
                                                        comment_body)
        db_comment = Comment.create(redmine_journal_id: journal['id'],
                                    github_comment_id: new_github_comment['id'],
                                    github_repo_name: project.github_repo_name)
      end
      puts 'Successfully %s GitHub comment with id %s in the "%s" repository/Redmine journal with id %s in the "%s" project!' \
           %[action, db_comment.github_comment_id.to_s, db_comment.github_repo_name, db_comment.redmine_journal_id.to_s, project.redmine_project_name]      
    end
  end

  def process_issue(issue)
    project = Project.where(:redmine_project_id => issue['project']['id']).first
    priority = Priority.where(redmine_priority_id: issue['priority']['id']).first.github_priority_name
    issue_type = IssueType.where(redmine_tracker_id: issue['tracker']['id']).first.github_issue_type_name
    status = Status.where(redmine_status_id: issue['status']['id']).first
    labels = [priority, issue_type]
    # get redmine issue to check attachments later
    redmine_issue = @redmine_api.get_issue(id=issue['id'])
    # see if issue exists already
    db_issue = Issue.where(redmine_id: issue['id']).first
    action = nil
    if db_issue.present?
      # get current issue for comparison
      github_issue = @github_api.get_issue(project.github_repo_owner, project.github_repo_name, db_issue.github_id)
      # extract current status label then decide whether to replace or not
      statuses = Status.all
      current_status = nil
      statuses.each do |s|
        if github_issue['labels'].detect {|l| l['name'] == s.github_status_name}
          current_status = s
          break
        end
      end   
      if current_status && current_status.id < status.id && current_status.id == db_issue.status_id
        labels.push(current_status.github_status_name)
      else
        labels.push(status.github_status_name)
      end
      # TODO leave labels which do not match any priority, issue type, or status name in the db
      # construct issue body
      issue_body = issue['description']
=begin
      # add author
      issue_body += '
### Author
%s' %[issue['author']['login']]
=end
      body = {
        :title => issue['subject'] != github_issue['title'] ? issue['subject'] : nil,
        :body => issue_body != github_issue['body'] ? issue_body : nil,
        :assignee => issue['assignee'] && (!github_issue['assignee'] || (issue['assignee']['login'] != github_issue['assignee']['login'])) ? issue['assignee']['login'] : nil,
        :labels => labels
        }.delete_if { |key, value| value.to_s.strip == '' }
      # edit GitHub issue unless nothing to update
      unless body.empty?
        @github_api.edit_issue(project.github_repo_owner,
                               project.github_repo_name,
                               db_issue.github_id,
                               body)
        Issue.update(db_issue.id,
                     redmine_id: db_issue.redmine_id,
                     github_id: db_issue.github_id,
                     github_repo_name: db_issue.github_repo_name,
                     status_id: status.id)
        action = 'updated'
      else
        action = 'skipped'
      end
    else     
      labels.push(status.github_status_name) 
      body = {
        :assignee => issue['assignee'] ? issue['assignee']['login'] : ENV['DEFAULT_ASSIGNEE'],
        :labels => labels
        }.delete_if { |key, value| value.to_s.strip == '' }
      # construct issue body
      issue_body = issue['description']
=begin      
      # add author
      issue_body += '
### Author
%s' %[issue['author']['login']]
=end
      # get attachments to add to issue body
      attachment_links = []
      redmine_issue['issue']['attachments'].each do |redmine_attachment|
        attachment_links.push(redmine_attachment['content_url'])
      end
      unless attachment_links.empty?
        issue_body += '
### Attachments'
        attachment_links.each do |attachment|
          issue_body += '
![](%s)' %[attachment]
        end
      end
      # create issue
      new_github_issue = @github_api.create_issue(project.github_repo_owner,
                                                  project.github_repo_name,
                                                  issue['subject'],
                                                  issue_body,
                                                  body)
      db_issue = Issue.create(redmine_id: issue['id'],
                              github_id: new_github_issue['number'],
                              github_repo_name: project.github_repo_name,
                              status_id: status.id)
      action = 'created'
    end
    puts 'Successfully %s GitHub issue number %s in the "%s" repository/Redmine issue with id %s in the "%s" project!' \
         %[action, db_issue.github_id.to_s, db_issue.github_repo_name, db_issue.redmine_id.to_s, project.redmine_project_name]
    # create/update comments if necessary
    handle_comments(issue)
  end

end
