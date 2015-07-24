require_relative '../test_helper'

class AppTest < WebhookTest

  def test_get_issues
    response =  get '/'
    assert_equal Issue.count, JSON.parse(response.body).count
  end

end