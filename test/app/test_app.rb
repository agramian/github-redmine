require_relative '../test_helper'

class FactoryTest < FunctionalTest

  def test_factory
    assert @issue.redmine_id == 1
    assert @issue.github_id == 1
  end
end