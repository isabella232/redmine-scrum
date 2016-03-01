class ChangeSprintsDates < ActiveRecord::Migration
  def self.up
    rename_column :sprints, :start_date, :sprint_start_date
    rename_column :sprints, :end_date, :sprint_end_date
  end

  def self.down
    rename_column :sprints, :sprint_start_date, :start_date
    rename_column :sprints, :sprint_end_date, :end_date
  end
end