# frozen_string_literal: true

module Authentication::ViaApiToken
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_with_api_token!
  end

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
      render_token_unauthorized
      return
    end
    @current_user = @current_workspace_member.user
    Current.workspace = @current_workspace_member.workspace
  end

  def render_token_unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
