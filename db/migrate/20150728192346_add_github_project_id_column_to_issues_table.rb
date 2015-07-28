class AddGithubProjectIdColumnToIssuesTable < ActiveRecord::Migration
  def change
    add_column :issues, :github_project_name, :string
  end
end
