require "scrum/gruff/themes"
require "scrum/gruff/line"

class SprintsController < ApplicationController

  menu_item :scrum
  model_object Sprint

  before_filter :find_model_object,
                :only => [:show, :edit, :update, :destroy, :edit_effort, :update_effort,
                          :burndown, :burndown_graph]
  before_filter :find_project_from_association,
                :only => [:show, :edit, :update, :destroy, :edit_effort, :update_effort,
                          :burndown, :burndown_graph]
  before_filter :find_project_by_project_id,
                :only => [:index, :new, :create, :change_task_status, :burndown_index]
  before_filter :authorize

  helper :custom_fields
  helper :scrum
  helper :timelog

  def index
    redirect_to sprint_path(@project.last_sprint)
  rescue
    render_404
  end

  def show
    redirect_to project_product_backlog_index_path(@project) if @sprint.is_product_backlog?
  end

  def new
    @sprint = Sprint.new(:project => @project)
    if params[:create_product_backlog]
      @sprint.name = l(:label_product_backlog)
      @sprint.start_date = @sprint.end_date = Date.today
    end
  end

  def create
    raise "Product backlog is already set" if params[:create_product_backlog] and
                                              !(@project.product_backlog.nil?)
    @sprint = Sprint.new(params[:sprint].merge(:user => User.current,
                                               :project => @project,
                                               :is_product_backlog => (!(params[:create_product_backlog].nil?))))
    if request.post? and @sprint.save
      if params[:create_product_backlog]
        @project.product_backlog = @sprint
        raise "Fail to update project with product backlog" unless @project.save!
      end
      flash[:notice] = l(:notice_successful_create)
      redirect_to settings_project_path(@project, :tab => "sprints")
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def edit
  end

  def update
    if @sprint.update_attributes(params[:sprint])
      flash[:notice] = l(:notice_successful_update)
      redirect_to settings_project_path(@project, :tab => "sprints")
    end
  end

  def destroy
    if @sprint.issues.any?
      flash[:error] = l(:notice_sprint_has_issues)
    else
      @sprint.destroy
    end
  rescue
    flash[:error] = l(:notice_unable_delete_sprint)
  ensure
    redirect_to settings_project_path(@project, :tab => "sprints")
  end

  def change_task_status
    task = Issue.find(params[:task].match(/^task_(\d+)$/)[1].to_i)
    task.init_journal(User.current)
    task.status = IssueStatus.find(params[:status].to_i)
    task.save!
    render :nothing => true
  end

  def edit_effort
  end

  def update_effort
    params[:user].each_pair do |user_id, days|
      user_id = user_id.to_i
      days.each_pair do |day, effort|
        day = day.to_i
        date = @sprint.start_date + day.to_i
        sprint_effort = SprintEffort.find(:first,
                                          :conditions => {:sprint_id => @sprint.id,
                                                          :user_id => user_id,
                                                          :date => date})
        if sprint_effort.nil?
          unless effort.blank?
            sprint_effort = SprintEffort.new(:sprint_id => @sprint.id,
                                             :user_id => user_id,
                                             :date => @sprint.start_date + day,
                                             :effort => effort.to_i)
          end
        elsif effort.blank?
          sprint_effort.destroy
          sprint_effort = nil
        else
          sprint_effort.effort = effort.to_i
        end
        sprint_effort.save! unless sprint_effort.nil?
      end
    end
    flash[:notice] = l(:notice_successful_update)
    redirect_to settings_project_path(@project, :tab => "sprints")
  end

  def burndown_index
    redirect_to burndown_sprint_path(@project.last_sprint)
  rescue
    render_404
  end

  def burndown
  end

  def burndown_graph
    fields = {};
    estimated_effort = [];
    pending_effort = []
    index = 0
    ((@sprint.start_date)..(@sprint.end_date)).each do |date|
      if @sprint.efforts.count(:conditions => ["date = ?", date]) > 0
        fields[index] = "#{I18n.l(date, :format => :scrum_day)}\n#{date.day}"
        index += 1
        efforts = @sprint.efforts.all(:conditions => ["date >= ?", date])
        estimated_effort << efforts.collect{|effort| effort.effort}.sum
        if date <= Date.today
          efforts = []
          @sprint.issues.each do |issue|
            efforts << issue.pending_efforts.last(:conditions => ["date <= ?", date])
          end
          pending_effort << efforts.compact.collect{|effort| effort.effort}.compact.sum
        end
      end
    end

    graph = Gruff::Line.new("800x500")
    graph.hide_title = true
    graph.theme = Scrum::Utils.graph_theme
    graph.labels = fields
    graph.data l(:label_estimated_effort), estimated_effort
    graph.data l(:field_pending_effort), pending_effort
    headers["Content-Type"] = "image/png"
    send_data(graph.to_blob, :type => "image/png", :disposition => "inline")
  end

end
