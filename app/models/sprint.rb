class Sprint < ActiveRecord::Base

  belongs_to :user
  belongs_to :project
  has_many :issues, :dependent => :destroy

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:project_id]
  validates_length_of :name, :maximum => 60
  validates_presence_of :name

  validates_presence_of :start_date

  validates_presence_of :end_date
  
  before_destroy :update_project_product_backlog

  def to_s
    name
  end

  def is_product_backlog?
    project and project.product_backlog == self
  end

  def user_stories
    user_stories_trackers = Setting.plugin_scrum[:user_story_trakers].collect{|tracker| tracker.to_i}
    issues.all(:conditions => {:tracker_id => user_stories_trackers},
               :order => "position ASC").select{|issue| issue.visible?}
  end

  def self.fields_for_order_statement(table = nil)
    table ||= table_name
    ["(CASE WHEN #{table}.end_date IS NULL THEN 1 ELSE 0 END)",
     "#{table}.end_date",
     "#{table}.name",
     "#{table}.id"]
  end

  scope :sorted, order(fields_for_order_statement)

private

  def update_project_product_backlog
    if is_product_backlog?
      project.product_backlog = nil
      project.save!
    end
  end

end
