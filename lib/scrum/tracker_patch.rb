require_dependency "tracker"

module Scrum
  module TrackerPatch
    def self.included(base)
      base.class_eval do

        def self.pbi_trackers_ids
          (Setting.plugin_scrum[:pbi_trakers] || []).collect{|tracker| tracker.to_i}
        end

        def self.pbi_trackers
          Tracker.all(conditions: {id: pbi_trackers_ids})
        end

        def is_pbi?
          pbi_trackers = (Setting.plugin_scrum[:pbi_trakers] || []).collect{|tracker| tracker.to_i}
          pbi_trackers.include?(id)
        end

        def self.task_trackers_ids
          (Setting.plugin_scrum[:task_trakers] || []).collect{|tracker| tracker.to_i}
        end

        def self.task_trackers
          Tracker.all(conditions: {id: task_trackers_ids})
        end

        def is_task?
          tasks_trackers = (Setting.plugin_scrum[:task_trakers] || []).collect{|tracker| tracker.to_i}
          tasks_trackers.include?(id)
        end

        def post_it_css_class
          setting_name = "tracker_#{id}_color"
          Setting.plugin_scrum[setting_name] || Redmine::Plugin::registered_plugins[:scrum].settings[:default][setting_name]
        end

      end
    end
  end
end
