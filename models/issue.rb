class Issue < ActiveRecord::Base
  validates_uniqueness_of :redmine_id, :allow_nil => true
  validates_uniqueness_of :github_id, :scope => :github_repo_name
end
