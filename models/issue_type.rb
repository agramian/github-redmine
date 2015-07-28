class IssueType < ActiveRecord::Base
  validates_presence_of :github_issue_type_name, :redmine_tracker_id
  validates_uniqueness_of :github_issue_type_name, :allow_nil => true
end
