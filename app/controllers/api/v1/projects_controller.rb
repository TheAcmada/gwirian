class Api::V1::ProjectsController < Api::V1::ApiController
  def index
    authorize! :read, Project
    projects = current_user.projects.select(:id, :name, :description, :context, :created_at, :updated_at)
    render json: projects
  end

  def show
    authorize! :read, @project
    render json: @project.as_json(only: [ :id, :name, :description, :context, :created_at, :updated_at ])
  end

  def search
    authorize! :read, @project
    limit = params[:limit].present? ? params[:limit].to_i.clamp(1, 100) : 20
    results = @project.search_content(params[:q].to_s.strip, limit: limit)
    render json: { results: results }
  end
end
