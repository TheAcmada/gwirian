class ProjectsController < ApplicationController
  before_action :set_project, only: [ :show, :history, :edit, :update, :destroy, :add_member, :remove_member, :update_member ]

  def index
    @projects = Current.user.projects
  end

  def show
    unless can? :read, @project
      render_alert("You are not authorized to view this project")
    end
  end

  def history
    unless can? :read, @project
      render_alert("You are not authorized to view this project")
      return
    end

    if params[:q].present?
      search_results = ScenarioExecution.search_by_project(params[:q], @project.id)
      ids = search_results.records.map(&:id)
      if ids.any?
        executions = @project.scenario_executions
          .where(id: ids)
          .includes(scenario: :feature, user: [])
          .reorder(executed_at: :desc)
      else
        executions = ScenarioExecution.none
      end
      @pagy, @executions = pagy(executions)
    else
      executions = @project.scenario_executions
        .includes(scenario: :feature, user: [])
        .reorder(executed_at: :desc)
      @pagy, @executions = pagy(executions)
    end
  end

  def new
    @project = Project.new
  end

  def create
    unless can? :create, Project
      render_alert("You are not authorized to create a project")
      return
    end

    @project = Project.new(project_params)
    if @project.save
      @project.project_members.create!(email: Current.user.email_address, role: "administrator", invitation_accepted: true)
      redirect_to project_path(@project), notice: "The project has been created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    unless can? :update, @project
      render_alert("You are not authorized to update this project")
      return
    end

    if @project.update(project_params)
      redirect_to edit_project_path(@project), notice: "The project has been updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless can? :destroy, @project
      render_alert("You are not authorized to delete this project")
      return
    end

    @project.destroy
    redirect_to projects_path, notice: "The project has been deleted successfully"
  end

  def add_member
    unless can? :add_member, @project
      render_alert("You are not authorized to add members to this project")
      return
    end

    # Check if the email is already in the project
    if @project.project_members.exists?(email: member_params[:email])
      alert = "The member is already in the project"
      if request.headers["HX-Request"]
        render partial: "projects/project_members", locals: { project: @project, alert: alert }
      else
        redirect_to projects_path, alert: alert
      end
      return
    end

    member = @project.project_members.new(member_params)
    if @project.admin?(Current.user) && params[:project_member][:role].present?
      # Only allow role assignment if user is admin and role is in permitted list
      permitted_role = params[:project_member][:role]
      if %w[administrator editor viewer].include?(permitted_role)
        member.role = permitted_role
      else
        member.role = "viewer"
      end
    else
      member.role = "viewer"
    end

    if member.save
      if request.headers["HX-Request"]
        render partial: "projects/project_members", locals: { project: @project, notice: "The member has been added successfully" }
      else
        redirect_to projects_path, notice: "The member has been added successfully"
      end
    else
      render_alert(member.errors.full_messages.to_sentence)
    end
  end

  def remove_member
    member = @project.project_members.find_by(id: params[:member_id])

    unless can? :remove, member
      render_alert("You are not authorized to remove members from this project")
      return
    end

    if member&.destroy
      if request.headers["HX-Request"]
        render partial: "projects/project_members", locals: { project: @project, notice: "The member has been removed successfully" }
      else
        redirect_to projects_path, notice: "The member has been removed successfully"
      end
    else
      render_alert("Could not remove the member")
    end
  end

  def update_member
    member = @project.project_members.find_by(id: params[:member_id])
    unless can? :update, member
      render_alert("You are not authorized to update members of this project")
      return
    end

    if member&.update(member_update_params)
      if request.headers["HX-Request"]
        render partial: "projects/project_members", locals: { project: @project, notice: "The member has been updated successfully" }
      else
        redirect_to projects_path, notice: "The member has been updated successfully"
      end
    else
      render_alert("Could not update the member")
    end
  end

  private
    def render_alert(message)
      redirect_to projects_path, alert: message
    end

    def set_project
      @project = Current.user.projects.find(params[:id])
    end

    def project_params
      params.require(:project).permit(:name, :description)
    end

    def member_params
      params.require(:project_member).permit(:email)
    end

    def member_update_params
      params.require(:project_member).permit(:role)
    end
end
