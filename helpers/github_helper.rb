Dir[File.dirname(__FILE__) + '/../models/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require file}

class GitHubHelper

  def initialize
    # initialize classes
    @github_api = GitHubApi.new
    @redmine_api = RedmineApi.new
  end

  def process_issue(issue)
    project = Project.where(:redmine_project_id => issue['project']['id']).first
    priority = Priority.where(redmine_priority_id: issue['priority']['id']).first.github_priority_name
    issue_type = IssueType.where(redmine_tracker_id: issue['tracker']['id']).first.github_issue_type_name
    status = Status.where(redmine_status_id: issue['status']['id']).first   
    labels = [priority, issue_type]
    # see if issue exists already
    db_issue = Issue.where(redmine_id: issue['id']).first
    action = nil
    if db_issue.present?
      # get current issue for comparison
      github_issue = @github_api.get_issue(project.github_repo_owner, project.github_repo_name, db_issue.github_id)      
      labels.push(status.github_status_name) 
=begin
      # TODO extract current status label then decide whether to replace or not
      # TODO leave labels which do not match any priority, issue type, or status name in the db
      # current status
      
      unless ['open', 'closed'].include? status || Status.where(github_status_name: status).first.id == db_issue.status_id
        labels.push(status)
      end
      # TODO only pass changed fields
      body = {
        'title' => github_issue['title'],
        'body' => github_issue['body'],
        'assignee' => github_issue['assignee'] ? github_issue['assignee']['login'] : ENV['DEFAULT_ASSIGNEE'],
        'milestone' => github_issue['milestone'],
        'labels' => github_issue['labels']
        }.delete_if { |key, value| value.to_s.strip == '' }
      # TODO check if attachments have changed or are not included in issue body and add
      # get redmine issue to check attachments
      redmine_issue = @redmine_api.get_issue(id=issue.redmine_id)
      github_attachments = github_issue['body'].scan(/\!\[.*\]\(.*\)/)
      redmine_issue['issue']['attachments'].each do |redmine_attachment|
        found = false 
        github_attachments.each do |github_attachment|
          if github_attachment.include? redmine_attachment['content_url']
            found = true
            break
          end
        end
        unless found
          body.gsub!(/\!\[.*\]\(.*\)/, '')
          break
        end
      end     
=end
      body = {
        :title => issue['subject'],
        :body => issue['description'],
        :assignee => issue['assignee'] ? issue['assignee']['login'] : ENV['DEFAULT_ASSIGNEE'],
        :labels => labels
        }.delete_if { |key, value| value.to_s.strip == '' }          
      # edit GitHub issue
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
=begin
  TODO handle attachments
=end      
      labels.push(status.github_status_name) 
      body = {
        :assignee => issue['assignee'] ? issue['assignee']['login'] : ENV['DEFAULT_ASSIGNEE'],
        :labels => labels
        }.delete_if { |key, value| value.to_s.strip == '' }
      new_github_issue = @github_api.create_issue(project.github_repo_owner,
                                                  project.github_repo_name,
                                                  issue['subject'],
                                                  issue['description'],
                                                  body)
      db_issue = Issue.create(redmine_id: issue['id'],
                              github_id: new_github_issue['number'],
                              github_repo_name: project.github_repo_name,
                              status_id: status.id)
      action = 'created'
    end
    puts 'Successfully %s GitHub issue number %s in the "%s" repository/Redmine issue with id %s in the "%s" project!' \
         %[action, db_issue.github_id.to_s, db_issue.github_repo_name, db_issue.redmine_id.to_s, project.redmine_project_name]
  end

end
