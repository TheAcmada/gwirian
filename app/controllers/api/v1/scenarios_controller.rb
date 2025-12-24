class Api::V1::ScenariosController < Api::V1::ApiController
  before_action :set_feature
  before_action :set_scenario, only: [ :show, :update, :destroy ]

  def index
    @scenarios = @feature.scenarios.order(:position)
    authorize! :read, Scenario.new(feature: @feature)
    render json: @scenarios.as_json(only: [ :id, :title, :given, :when, :then, :position, :feature_id, :created_at, :updated_at ])
  end

  def show
    authorize! :read, @scenario
    render json: @scenario.as_json(only: [ :id, :title, :given, :when, :then, :position, :feature_id, :created_at, :updated_at ])
  end

  def create
    @scenario = @feature.scenarios.new(scenario_params)
    authorize! :create, @scenario

    if @scenario.save
      render json: @scenario.as_json(only: [ :id, :title, :given, :when, :then, :position, :feature_id, :created_at, :updated_at ]), status: :created
    else
      render json: { errors: @scenario.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize! :update, @scenario

    if @scenario.update(scenario_params)
      render json: @scenario.as_json(only: [ :id, :title, :given, :when, :then, :position, :feature_id, :created_at, :updated_at ])
    else
      render json: { errors: @scenario.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, @scenario

    if @scenario.destroy
      render json: { message: "Scenario deleted successfully" }, status: :ok
    else
      render json: { errors: @scenario.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_feature
    @feature = @project.features.find_by(id: params[:feature_id])
    unless @feature
      render json: { error: "Feature not found" }, status: :not_found and return
    end
  end

  def set_scenario
    @scenario = @feature.scenarios.find_by(id: params[:id])
    unless @scenario
      render json: { error: "Scenario not found" }, status: :not_found and return
    end
  end

  def scenario_params
    params.require(:scenario).permit(:title, :given, :when, :then, :position)
  end

  rescue_from CanCan::AccessDenied do |exception|
    render json: { error: "Access denied" }, status: :forbidden
  end
end
