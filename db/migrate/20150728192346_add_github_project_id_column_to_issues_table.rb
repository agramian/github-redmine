class AddGithubProjectIdColumnToIssuesTable < ActiveRecord::Migration
  def change
    add_column :issues, :github_repo_name, :string
  end
end
