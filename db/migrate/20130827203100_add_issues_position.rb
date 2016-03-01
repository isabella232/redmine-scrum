class AddIssuesPosition < ActiveRecord::Migration
  def up
    add_column :issues, :position, :integer
    add_index :issues, [:position], :name => "issues_position"
  end

  def down
    remove_column :issues, :position
  end
end
