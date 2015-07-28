class Project < ActiveRecord::Base
  validates_presence_of :github_repo_name, :github_repo_owner, :redmine_project_id
  validates_uniqueness_of :github_repo_name, :github_repo_owner, :redmine_project_id, :redmine_project_name, :allow_nil => true
end
