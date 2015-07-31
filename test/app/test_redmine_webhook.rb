require_relative '../test_helper'

class RedmineWebhookTest < WebhookTest

  def test_issue_opened_skip_new
    response = post '/redmine_hook', @redmine_events['opened']
    assert_equal 204, response.status
    issues = Issue.find(:all)
    assert_equal 0, issues.count
  end

  def test_issue_opened
    data = JSON.parse(@redmine_events['opened'])
    status = Status.where(github_status_name: 'In Progress').first
    data['payload']['issue']['status']['id'] = status.redmine_status_id
    response = post '/redmine_hook', data.to_json
    assert_equal 200, response.status
    issues = Issue.find(:all)
    assert_equal 1, issues.count
  end  

  def test_issue_updated
    data = JSON.parse(@redmine_events['opened'])
    status = Status.where(github_status_name: 'In Progress').first
    data['payload']['issue']['status']['id'] = status.redmine_status_id
    response = post '/redmine_hook', data.to_json
    assert_equal 200, response.status
    issues = Issue.find(:all)
    assert_equal 1, issues.count
    # update
    data = JSON.parse(@redmine_events['updated'])
    status = Status.where(github_status_name: 'On Hold').first
    data['payload']['issue']['status']['id'] = status.redmine_status_id
    data['payload']['issue']['subject'] += " Edited"
    response = post '/redmine_hook', data.to_json
    assert_equal 200, response.status
    issues = Issue.find(:all)
    assert_equal 1, issues.count    
  end  

end
