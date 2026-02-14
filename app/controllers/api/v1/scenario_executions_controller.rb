class Api::V1::ScenarioExecutionsController < Api::V1::ApiController
  before_action :set_feature
  before_action :set_scenario
  before_action :set_scenario_execution, only: [ :show, :update, :destroy ]

  def index
    @scenario_executions = @scenario.scenario_executions.latest_first
    authorize! :read, ScenarioExecution.new(scenario: @scenario)
    render json: @scenario_executions.as_json(only: [ :id, :scenario_id, :user_id, :status, :notes, :executed_at, :created_at, :updated_at ])
  end

  def show
    authorize! :read, @scenario_execution
    render json: @scenario_execution.as_json(only: [ :id, :scenario_id, :user_id, :status, :notes, :executed_at, :created_at, :updated_at ])
  end

  def create
    @scenario_execution = @scenario.scenario_executions.new(scenario_execution_params)
    @scenario_execution.user = current_user
    authorize! :create, @scenario_execution

    if @scenario_execution.save
      render json: @scenario_execution.as_json(only: [ :id, :scenario_id, :user_id, :status, :notes, :executed_at, :created_at, :updated_at ]), status: :created
    else
      render json: { errors: @scenario_execution.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize! :update, @scenario_execution

    if @scenario_execution.update(scenario_execution_params)
      render json: @scenario_execution.as_json(only: [ :id, :scenario_id, :user_id, :status, :notes, :executed_at, :created_at, :updated_at ])
    else
      render json: { errors: @scenario_execution.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, @scenario_execution

    if @scenario_execution.destroy
      render json: { message: "Scenario execution deleted successfully" }, status: :ok
    else
      render json: { errors: @scenario_execution.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_feature
    @feature = @project.features.find(params[:feature_id])
  end

  def set_scenario
    @scenario = @feature.scenarios.find(params[:scenario_id])
  end

  def set_scenario_execution
    @scenario_execution = @scenario.scenario_executions.find(params[:id])
  end

  def scenario_execution_params
    params.require(:scenario_execution).permit(:status, :notes, :executed_at)
  end
end
