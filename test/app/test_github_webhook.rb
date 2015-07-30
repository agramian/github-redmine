require_relative '../test_helper'

class GitHubWebhookTest < WebhookTest

  def test_issue_opened
    response = post '/github_hook', @github_events['opened']
    assert_equal 200, response.status
    issues = Issue.find(:all)
    assert_equal 1, issues.count
    assert_equal issues.first.status_id, Status.where(github_status_name: 'open').first.id
  end

  def test_comment_created
    response = post '/github_hook', @github_events['opened']
    response = post '/github_hook', @github_events['comment_created']
    assert_equal 1, Issue.find(:all).count
    assert_equal 1, Comment.find(:all).count
    assert_equal 200, response.status
  end

  def test_issue_assigned
    response = post '/github_hook', @github_events['opened']
    assert_equal 200, response.status
    response = post '/github_hook', @github_events['assigned']
    assert_equal 200, response.status
    assert_equal 1, Issue.find(:all).count
    issue = Issue.find(:all).first
    data = JSON.parse(@github_events['assigned'])
    redmine_assignee = @redmine_api.get_user(@redmine_api.get_issue(issue.redmine_id)['issue']['assigned_to']['id'])
    assert_equal data['issue']['assignee']['login'], redmine_assignee['user']['login']
  end

  def test_issue_closed
    response = post '/github_hook', @github_events['opened']
    assert_equal 200, response.status
    response = post '/github_hook', @github_events['closed']
    assert_equal 200, response.status    
    issues = Issue.find(:all)
    assert_equal 1, issues.count
    assert_equal issues.first.status_id, Status.where(github_status_name: 'closed').first.id
  end
    # change status
  def test_issue_labeled_change_issue_type
    response = post '/github_hook', @github_events['opened']
    assert_equal 200, response.status
    issues = Issue.find(:all)
    assert_equal 1, issues.count    
    redmine_tracker = @redmine_api.get_issue(Issue.find(:all).first.redmine_id)['issue']['tracker']
    assert_equal IssueType.where(github_issue_type_name: 'bug').first.redmine_tracker_id, redmine_tracker['id']
    # change label to enhancement
    data = JSON.parse(@github_events['labeled'])
    data['issue']['labels'][0]['name'] = 'enhancement'
    response = post '/github_hook', data.to_json
    assert_equal 200, response.status    
    issues = Issue.find(:all)
    assert_equal 1, issues.count
    redmine_tracker = @redmine_api.get_issue(Issue.find(:all).first.redmine_id)['issue']['tracker']
    assert_equal IssueType.where(github_issue_type_name: 'enhancement').first.redmine_tracker_id, redmine_tracker['id']
  end

  def test_issue_labeled_change_issue_priority
    data = JSON.parse(@github_events['labeled'])
    ['1 - Mild', '5 - Suicidal'].each do |github_priority_name|
      data['issue']['labels'][0]['name'] = github_priority_name
      response = post '/github_hook', data.to_json
      assert_equal 200, response.status    
      issues = Issue.find(:all)
      assert_equal 1, issues.count
      redmine_priority = @redmine_api.get_issue(Issue.find(:all).first.redmine_id)['issue']['priority']
      puts github_priority_name, redmine_priority
      assert_equal Priority.where(github_priority_name: github_priority_name).first.redmine_priority_id, redmine_priority['id']
    end
  end

end
