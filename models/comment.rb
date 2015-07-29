class Comment < ActiveRecord::Base
  validates_presence_of :redmine_journal_id, :github_comment_id, :github_repo_name
  validates_uniqueness_of :redmine_journal_id
  validates_uniqueness_of :github_comment_id, :scope => :github_repo_name
end
