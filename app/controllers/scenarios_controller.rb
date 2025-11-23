class ScenariosController < ApplicationController
  before_action :set_project
  before_action :set_feature
  before_action :set_scenario, only: [ :update ]

  def create
    @scenario = @feature.scenarios.new(title: "New scenario")
    authorize! :create, @scenario

    if @scenario.save
      if request.headers["HX-Request"]
        render ScenarioComponent.new(scenario: @scenario, feature: @feature, project: @project), layout: false
      else
        redirect_to project_feature_path(@project, @feature), notice: "Scenario created successfully"
      end
    else
      if request.headers["HX-Request"]
        head :unprocessable_entity
      else
        redirect_to project_feature_path(@project, @feature), alert: "Failed to create scenario"
      end
    end
  end

  def update
    authorize! :update, @scenario

    if @scenario.update(scenario_params)
      if request.headers["HX-Request"]
        # Check if this is a title-only update by checking if only title is in params
        if scenario_params.keys == [ "title" ] || (scenario_params.keys.include?("title") && scenario_params.keys.length == 1)
          render ScenarioTitleComponent.new(scenario: @scenario, feature: @feature, project: @project), layout: false
        else
          render ScenarioComponent.new(scenario: @scenario, feature: @feature, project: @project), layout: false
        end
      else
        redirect_to project_feature_path(@project, @feature), notice: "Scenario updated successfully"
      end
    else
      if request.headers["HX-Request"]
        if scenario_params.keys == [ "title" ] || (scenario_params.keys.include?("title") && scenario_params.keys.length == 1)
          render ScenarioTitleComponent.new(scenario: @scenario, feature: @feature, project: @project), layout: false, status: :unprocessable_entity
        else
          render ScenarioComponent.new(scenario: @scenario, feature: @feature, project: @project), layout: false, status: :unprocessable_entity
        end
      else
        redirect_to project_feature_path(@project, @feature), alert: "Failed to update scenario"
      end
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
    @scenario = @feature.scenarios.find(params[:id])
  end

  def scenario_params
    params.require(:scenario).permit(:title, :given, :when, :then)
  end
end
