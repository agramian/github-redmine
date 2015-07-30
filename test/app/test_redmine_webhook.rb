require_relative '../test_helper'

class RedmineWebhookTest < WebhookTest

  def test_issue_opened
    response = post '/redmine_hook', @redmine_events['opened']
    #assert_equal Issue.count, JSON.parse(response.body).count
  end

end
