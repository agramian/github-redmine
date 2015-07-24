require_relative '../test_helper'

class RedmineWebhookTest < WebhookTest

  def test_factory
    puts @redmine_events['opened']
  end

end
