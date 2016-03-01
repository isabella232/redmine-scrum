class AddIssuesSprintId < ActiveRecord::Migration
  def up
    add_column :issues, :sprint_id, :integer
    add_index :issues, [:sprint_id], :name => "issues_sprint_id"
  end

  def down
    remove_column :issues, :sprint_id
  end
end
