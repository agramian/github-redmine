class Mapping < ActiveRecord::Migration
  def change
    create_table :priorities do |t|
      t.string  :github_priority_name
      t.integer :redmine_priority_id
      t.string  :redmine_priority_name
    end
    create_table :projects do |t|
      t.string :github_repo_name
      t.string  :github_repo_owner
      t.integer :redmine_project_id
      t.string  :redmine_project_name
    end
    create_table :statuses do |t|
      t.string :github_status_name
      t.integer :redmine_status_id
      t.string  :redmine_status_name
    end
    create_table :issue_types do |t|
      t.string :github_issue_type_name
      t.integer :redmine_tracker_id
      t.string  :redmine_tracker_name
    end    
  end
end
