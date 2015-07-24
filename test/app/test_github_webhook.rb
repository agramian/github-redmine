require_relative '../test_helper'

class GitHubWebhookTest < WebhookTest

  def test_factory
    puts @github_events['opened']
  end

end
