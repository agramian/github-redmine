class Status < ActiveRecord::Base
  validates_presence_of :github_status_name, :redmine_status_id
  validates_uniqueness_of :github_status_name, :allow_nil => true
end
