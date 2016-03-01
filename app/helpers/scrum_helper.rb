# Copyright © Emilio González Montaña
# Licence: Attribution & no derivates
#   * Attribution to the plugin web page URL should be done if you want to use it.
#     https://redmine.ociotec.com/projects/redmine-plugin-scrum
#   * No derivates of this plugin (or partial) are allowed.
# Take a look to licence.txt file at plugin root folder for further details.

module ScrumHelper

  include ProjectsHelper

  def render_hours(hours, options = {})
    if hours.nil?
      ""
    else
      if hours.is_a?(Integer)
        text = ("%d" % hours) unless options[:ignore_zero] and hours == 0
      elsif hours.is_a?(Float)
        text = ("%g" % hours) unless options[:ignore_zero] and hours == 0.0
      else
        text = hours unless options[:ignore_zero] and (hours.blank? or (hours == "0"))
      end
      unless text.blank?
        text = "#{text}h"
        unless options[:link].nil?
          text = link_to(text, options[:link])
        end
        render :inline => "<span title=\"#{options[:title]}\">#{text}</span>"
      end
    end
  end

  def render_pbi_left_header(pbi)
    parts = []
    if Scrum::Setting.render_position_on_pbi
      parts << "#{l(:field_position)}: #{pbi.position}"
    end
    if Scrum::Setting.render_category_on_pbi and pbi.category
      parts << "#{l(:field_category)}: #{h(pbi.category.name)}"
    end
    if Scrum::Setting.render_version_on_pbi and pbi.fixed_version
      parts << "#{l(:field_fixed_version)}: #{link_to_version(pbi.fixed_version)}"
    end
    render :inline => parts.join(", ")
  end

  def render_pbi_right_header(pbi)
    parts = []
    if Scrum::Setting.render_author_on_pbi
      parts << authoring(pbi.created_on, pbi.author)
    end
    if Scrum::Setting.render_updated_on_pbi and pbi.created_on != pbi.updated_on
      parts << "#{l(:label_updated_time, time_tag(pbi.updated_on))}"
    end
    render :inline => parts.join(", ")
  end

  def render_issue_icons(issue)
    icons = []
    if ((issue.is_pbi? and Scrum::Setting.render_pbis_deviations) or
        (issue.is_task? and Scrum::Setting.render_tasks_deviations))
      deviation_ratio = issue.deviation_ratio
      unless deviation_ratio.nil?
        if deviation_ratio >= Scrum::Setting.major_deviation_ratio
          icons << render_issue_icon(MAJOR_DEVIATION_ICON, deviation_ratio)
        elsif deviation_ratio >= Scrum::Setting.minor_deviation_ratio
          icons << render_issue_icon(MINOR_DEVIATION_ICON, deviation_ratio)
        elsif deviation_ratio <= Scrum::Setting.below_deviation_ratio
          icons << render_issue_icon(BELOW_DEVIATION_ICON, deviation_ratio)
        end
      end
    end
    render :inline => icons.join("\n")
  end

  DEVIATION_ICONS = [MAJOR_DEVIATION_ICON = "exclamation.png",
                     MINOR_DEVIATION_ICON = "warning.png",
                     BELOW_DEVIATION_ICON = "lightning.png"]

private

  def render_issue_icon(image_path, deviation_ratio = nil)
    content_tag("div") do
      options = {:class => "float float-icon"}
      options[:title] = l(:label_deviation, :deviation => deviation_ratio) unless deviation_ratio.nil?
      image_tag(image_path, options)
    end
  end

end
