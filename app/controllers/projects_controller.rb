require "zip"

class ProjectsController < ApplicationController
  before_action :require_workspace
  before_action :set_project, only: [ :show, :search, :history, :edit, :update, :destroy, :export_bdd, :add_member, :remove_member, :update_member ]

  def index
    @projects = workspace_projects.order(:name).includes(scenarios: :scenario_executions)
  end

  def show
    unless can? :read, @project
      render_alert("You are not authorized to view this project")
    end
  end

  def search
    unless can? :read, @project
      render json: { results: [] }, status: :forbidden
      return
    end

    q = params[:q].to_s.strip
    results = []

    if q.present?
      begin
        raw = @project.search_content(q, limit: 10)
        results = raw.map do |r|
          case r[:type]
          when "feature"
            {
              type: "feature",
              title: r[:title],
              subtitle: "Feature",
              url: project_feature_path(@project, r[:id]),
              status: r[:status],
              status_label: r[:status] ? status_label_for(r[:status]) : nil
            }
          when "scenario"
            {
              type: "scenario",
              title: r[:title],
              subtitle: "Feature: #{r[:feature_title]}",
              url: project_feature_path(@project, r[:feature_id]),
              status: r[:status],
              status_label: status_label_for(r[:status])
            }
          end
        end.compact
      rescue StandardError
        results = []
      end
    end

    render json: { results: results }
  end

  def export_bdd
    unless can? :read, @project
      render_alert("You are not authorized to export this project")
      return
    end

    entries = @project.gherkin_export_entries
    zip_filename = "#{@project.name.parameterize.presence || 'project'}.zip"

    buffer = Zip::OutputStream.write_buffer do |zio|
      entries.each do |filename, content|
        zio.put_next_entry(filename)
        zio.write(content)
      end
    end

    send_data buffer.string,
              type: "application/zip",
              disposition: "attachment",
              filename: zip_filename
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
    unless can? :create, Project
      redirect_to projects_path, alert: "You are not authorized to create a project"
      return
    end
    @project = Project.new
  end

  def create
    unless can? :create, Project
      render_alert("You are not authorized to create a project")
      return
    end

    @project = Current.workspace.projects.new(project_params)
    if @project.save
      @project.project_members.create!(email: Current.user.email_address, role: "administrator")
      redirect_to project_features_path(@project), notice: "The project has been created successfully"
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

    email = member_params[:email]&.strip&.downcase

    # Check if the email belongs to a current workspace member
    user = User.find_by(email_address: email)
    unless user && Current.workspace.workspace_members.current_member.exists?(user_id: user.id)
      alert = "This user is not a member of the workspace"
      if htmx_request?
        render partial: "projects/project_members", locals: { project: @project, alert: alert }
      else
        redirect_to projects_path, alert: alert
      end
      return
    end

    # Check if the email is already in the project
    if @project.project_members.exists?(email: email)
      alert = "The member is already in the project"
      if htmx_request?
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
      if htmx_request?
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
      if htmx_request?
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
      if htmx_request?
        render partial: "projects/project_members", locals: { project: @project, notice: "The member has been updated successfully" }
      else
        redirect_to projects_path, notice: "The member has been updated successfully"
      end
    else
      render_alert("Could not update the member")
    end
  end

  private

  def status_label_for(status)
    { "passed" => "Passed", "failed" => "Failed", "pending" => "Pending" }.fetch(status, "Pending")
  end

  def render_alert(message)
    redirect_to projects_path, alert: message
  end

  def set_project
    @project = workspace_projects.order(:name).find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :context)
  end

  def member_params
    params.require(:project_member).permit(:email)
  end

  def member_update_params
    params.require(:project_member).permit(:role)
  end
end
