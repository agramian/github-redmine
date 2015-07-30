require_relative '../test_helper'

class GitHubWebhookTest < WebhookTest

  def test_issue_opened
    response = post '/github_hook', @github_events['closed']
  end

end
