# Copyright © Emilio González Montaña
# Licence: Attribution & no derivates
#   * Attribution to the plugin web page URL should be done if you want to use it.
#     https://redmine.ociotec.com/projects/redmine-plugin-scrum
#   * No derivates of this plugin (or partial) are allowed.
# Take a look to licence.txt file at plugin root folder for further details.

require_dependency "project"

module Scrum
  module ProjectPatch
    def self.included(base)
      base.class_eval do

        belongs_to :product_backlog, :class_name => "Sprint"
        has_many :sprints, -> { where(:is_product_backlog => false).order("sprint_start_date ASC, name ASC") },
                 :dependent => :destroy
        has_many :sprints_and_product_backlog, -> { order("sprint_start_date ASC, name ASC") },
                 :class_name => "Sprint", :dependent => :destroy

        def last_sprint
          sprints.sort{|a, b| a.sprint_end_date <=> b.sprint_end_date}.last
        end

        def story_points_per_sprint
          i = self.sprints.length - 1
          sprints_count = 0
          story_points_per_sprint = 0.0
          scheduled_story_points_per_sprint = 0.0
          while (sprints_count < Scrum::Setting.product_burndown_sprints and i >= 0)
            story_points = self.sprints[i].story_points
            scheduled_story_points = self.sprints[i].scheduled_story_points
            unless story_points.nil? or scheduled_story_points.nil?
              story_points_per_sprint += story_points
              scheduled_story_points_per_sprint += scheduled_story_points
              sprints_count += 1
            end
            i -= 1
          end
          story_points_per_sprint = filter_story_points(story_points_per_sprint, sprints_count)
          scheduled_story_points_per_sprint = filter_story_points(scheduled_story_points_per_sprint, sprints_count)
          return [story_points_per_sprint, scheduled_story_points_per_sprint, sprints_count]
        end

      private

        def filter_story_points(story_points, sprints_count)
          story_points /= sprints_count if story_points > 0 and sprints_count > 0
          story_points = 1 if story_points == 0
          story_points = story_points.round(2)
          return story_points
        end

      end
    end
  end
end
