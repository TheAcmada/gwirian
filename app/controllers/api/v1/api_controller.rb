class Api::V1::ApiController < ActionController::Base
  before_action :authenticate_with_api_token!
  before_action :set_project, if: -> { params[:project_id].present? }

  def current_user
    @current_user
  end

  private

  def authenticate_with_api_token!
    token = request.headers["authorization"]&.split(" ")&.last || params[:api_token]
    @current_user = User.find_by(api_token: token)
    unless @current_user&.api_token_valid?
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  protected

  def set_project
    @project = current_user.projects.find_by(id: params[:project_id])
    unless @project
      render json: { error: "Project not found" }, status: :not_found and return
    end
  end
end
