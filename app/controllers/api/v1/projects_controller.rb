class Api::V1::ProjectsController < Api::V1::ApiController
  def index
    authorize! :read, Project
    projects = current_user.projects.select(:id, :name, :description, :created_at, :updated_at)
    render json: projects
  end

  def show
    authorize! :read, @project
    render json: @project.as_json(only: [ :id, :name, :description, :created_at, :updated_at ])
  end
end
