class StepsController < ApplicationController
  before_action :set_project
  before_action :set_feature
  before_action :set_scenario
  before_action :set_step, only: [ :update, :destroy ]

  def create
    @step = @scenario.steps.new(step_params)
    authorize! :create, @step

    # Handle position for inserting after a specific step
    if params[:after_position].present?
      @step.position = params[:after_position].to_i + 1
    end

    if @step.save
      if request.headers["HX-Request"]
        render Steps::Component.new(
          step: @step,
          scenario: @scenario,
          feature: @feature,
          project: @project
        ), layout: false
      else
        redirect_to project_feature_path(@project, @feature), notice: "Step created successfully"
      end
    else
      if request.headers["HX-Request"]
        head :unprocessable_entity
      else
        redirect_to project_feature_path(@project, @feature), alert: "Failed to create step"
      end
    end
  end

  def update
    authorize! :update, @step

    if @step.update(step_params)
      if request.headers["HX-Request"]
        head :ok
      else
        redirect_to project_feature_path(@project, @feature), notice: "Step updated successfully"
      end
    else
      if request.headers["HX-Request"]
        head :unprocessable_entity
      else
        redirect_to project_feature_path(@project, @feature), alert: "Failed to update step"
      end
    end
  end

  def destroy
    authorize! :destroy, @step
    @step.destroy!

    if request.headers["HX-Request"]
      head :ok
    else
      redirect_to project_feature_path(@project, @feature), notice: "Step deleted successfully"
    end
  end

  private

  def set_project
    @project = Current.user.projects.find(params[:project_id])
  end

  def set_feature
    @feature = @project.features.find(params[:feature_id])
  end

  def set_scenario
    @scenario = @feature.scenarios.find(params[:scenario_id])
  end

  def set_step
    @step = @scenario.steps.find(params[:id])
  end

  def step_params
    params.require(:step).permit(:action)
  end
end
