# frozen_string_literal: true

class Api::V1::ApiController < ActionController::Base
  include Authentication::ViaApiToken
  include ProjectAccessible

  skip_before_action :verify_authenticity_token
  before_action :set_project, if: -> { params[:project_id].present? }

  rescue_from ActiveRecord::RecordNotFound do |e|
    message = record_not_found_message(e)
    render json: { error: message }, status: :not_found
  end

  rescue_from CanCan::AccessDenied do
    render json: { error: "Access denied" }, status: :forbidden
  end

  def current_user
    @current_user
  end

  def current_workspace_member
    @current_workspace_member
  end

  protected

  def record_not_found_message(exception)
    model_name = exception.respond_to?(:model) && exception.model ? (exception.model.is_a?(Class) ? exception.model.name : exception.model.to_s) : nil
    case model_name
    when "Project" then "Project not found"
    when "Feature" then "Feature not found"
    when "Scenario" then "Scenario not found"
    when "ScenarioExecution" then "Scenario execution not found"
    else exception.message
    end
  end

  def set_project
    @project = accessible_projects.find(params[:project_id])
  end
end
