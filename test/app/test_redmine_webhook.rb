require_relative '../test_helper'

class RedmineWebhookTest < WebhookTest

  def create_redmine_issue
    data = JSON.parse(@redmine_events['opened'])
    status = Status.where(github_status_name: 'In Progress').first
    data['payload']['issue']['status']['id'] = status.redmine_status_id
    # create redmine issue
    project = Project.where(:redmine_project_name => data['payload']['issue']['project']['name']).first
    new_redmine_issue = @redmine_api.create_issue(project_id=project.redmine_project_id,
                                                  subject=data['payload']['issue']['subject'],
                                                  description=data['payload']['issue']['body'])
    data['payload']['issue']['id'] = new_redmine_issue['issue']['id']
    return data
  end

  def test_issue_opened_skip_new
    response = post '/redmine_hook', @redmine_events['opened']
    assert_equal 204, response.status
    issues = Issue.all
    assert_equal 0, issues.count
  end

  def test_issue_opened
    data = create_redmine_issue                           
    response = post '/redmine_hook', data.to_json
    assert_equal 200, response.status
    issues = Issue.all
    assert_equal 1, issues.count
  end  

  def test_issue_updated
    # create
    data = create_redmine_issue                           
    response = post '/redmine_hook', data.to_json
    assert_equal 200, response.status
    issues = Issue.all
    assert_equal 1, issues.count
    # update
    issue_id = data['payload']['issue']['id']
    data = JSON.parse(@redmine_events['updated'])
    data['payload']['issue']['id'] = issue_id
    status = Status.where(github_status_name: 'On Hold').first
    data['payload']['issue']['status']['id'] = status.redmine_status_id
    data['payload']['issue']['subject'] += " Edited"
    response = post '/redmine_hook', data.to_json
    assert_equal 200, response.status
    issues = Issue.all
    assert_equal 1, issues.count    
  end  

=begin    
    db_issue = Issue.create(redmine_id: new_redmine_issue['issue']['id'],
                            github_id: issue['number'],
                            github_repo_name: project.github_repo_name,
                            status_id: status_id.id)
=end
=begin
  def test_issue_comment
    # create
    data = create_redmine_issue                           
    response = post '/redmine_hook', data.to_json
    assert_equal 200, response.status
    issues = Issue.all
    assert_equal 1, issues.count
    # update
    issue_id = data['payload']['issue']['id']
    data = JSON.parse(@redmine_events['updated'])
    data['payload']['issue']['id'] = issue_id
    status = Status.where(github_status_name: 'On Hold').first
    data['payload']['issue']['status']['id'] = status.redmine_status_id
    data['payload']['issue']['subject'] += " Edited"
    response = post '/redmine_hook', data.to_json
    assert_equal 200, response.status
    issues = Issue.all
    assert_equal 1, issues.count    
  end
=end
end
