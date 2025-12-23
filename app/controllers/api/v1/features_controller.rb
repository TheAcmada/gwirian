class Api::V1::FeaturesController < Api::V1::ApiController
  before_action :set_feature, only: [ :show, :update, :destroy ]

  def index
    @features = @project.features.order(:title)
    authorize! :read, Feature.new(project: @project)
    render json: @features.as_json(only: [ :id, :title, :description, :created_at, :updated_at, :project_id ])
  end

  def show
    authorize! :read, @feature
    render json: @feature.as_json(only: [ :id, :title, :description, :created_at, :updated_at, :project_id ])
  end

  def create
    @feature = @project.features.new(feature_params)
    authorize! :create, @feature

    if @feature.save
      render json: @feature.as_json(only: [ :id, :title, :description, :created_at, :updated_at, :project_id ]), status: :created
    else
      render json: { errors: @feature.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize! :update, @feature

    if @feature.update(feature_params)
      render json: @feature.as_json(only: [ :id, :title, :description, :created_at, :updated_at, :project_id ])
    else
      render json: { errors: @feature.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, @feature

    if @feature.destroy
      render json: { message: "Feature deleted successfully" }, status: :ok
    else
      render json: { errors: @feature.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_feature
    @feature = @project.features.find_by(id: params[:id])
    unless @feature
      render json: { error: "Feature not found" }, status: :not_found and return
    end
  end

  def feature_params
    params.require(:feature).permit(:title, :description, :tag_list)
  end

  rescue_from CanCan::AccessDenied do |exception|
    render json: { error: "Access denied" }, status: :forbidden
  end
end
