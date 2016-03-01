class SprintsController < ApplicationController

  menu_item :scrum
  model_object Sprint

  before_filter :find_model_object, :only => [:show, :edit, :update, :destroy]
  before_filter :find_project_from_association, :only => [:show, :edit, :update, :destroy]
  before_filter :find_project_by_project_id, :only => [:index, :new, :create, :change_task_status]
  before_filter :authorize

  helper :scrum
  helper :timelog
  helper :custom_fields

  def index
    redirect_to sprint_path(@project.last_sprint)
  rescue
    render_404
  end

  def show
    redirect_to project_product_backlog_index_path(@project) if @sprint.is_product_backlog
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

end
