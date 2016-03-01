class ChangeSprintEffortsEffort < ActiveRecord::Migration
  def self.up
    change_column :sprint_efforts, :effort, :float
  end

  def self.down
    change_column :sprint_efforts, :effort, :integer
  end
end