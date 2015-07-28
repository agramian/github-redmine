class Priority < ActiveRecord::Base
  validates_presence_of :github_priority_name, :redmine_priority_id
  validates_uniqueness_of :github_priority_name, :redmine_priority_id, :redmine_priority_name, :allow_nil => true
end
