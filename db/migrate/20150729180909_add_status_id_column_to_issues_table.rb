class AddStatusIdColumnToIssuesTable < ActiveRecord::Migration
  def change
    add_column :issues, :status_id, :int
  end
end
