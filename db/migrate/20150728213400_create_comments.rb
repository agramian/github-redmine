class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :redmine_journal_id
      t.integer :github_comment_id
      t.string  :github_repo_name
      t.timestamps
    end
  end
end
