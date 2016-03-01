require_dependency "tracker"

module Scrum
  module TrackerPatch
    def self.included(base)
      base.class_eval do

        def is_user_story?
          user_stories_trackers = Setting.plugin_scrum[:user_story_trakers].collect{|tracker| tracker.to_i}
          user_stories_trackers.include?(id)
        end

        def post_it_css_class
          setting_name = "tracker_#{id}_color"
          Setting.plugin_scrum[setting_name] || Redmine::Plugin::registered_plugins[:scrum].settings[:default][setting_name]
        end

      end
    end
  end
end
