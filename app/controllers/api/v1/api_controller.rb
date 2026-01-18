class Api::V1::ApiController < ActionController::Base
  before_action :authenticate_with_api_token!
  before_action :set_project, if: -> { params[:project_id].present? }

  def current_user
    @current_user
  end

  def current_workspace_member
    @current_workspace_member
  end

  private

  def authenticate_with_api_token!
    token = request.headers["authorization"]&.split(" ")&.last || params[:api_token]
    @current_workspace_member = WorkspaceMember.find_by(api_token: token)
    unless @current_workspace_member&.api_token_valid?
      render json: { error: "Unauthorized" }, status: :unauthorized
      return
    end
    @current_user = @current_workspace_member.user
    Current.workspace = @current_workspace_member.workspace
  end

  protected

  def set_project
    @project = Current.workspace.projects
      .joins(:project_members)
      .where(project_members: { email: current_user.email_address })
      .find_by(id: params[:project_id])
    unless @project
      render json: { error: "Project not found" }, status: :not_found and return
    end
  end
end
