class ScenarioTitleComponent < ApplicationComponent
  def initialize(scenario:, feature:, project:)
    @scenario = scenario
    @feature = feature
    @project = project
  end

  def update_path
    project_feature_scenario_path(@project, @feature, @scenario)
  end

  def form_id
    "scenario-title-form-#{@scenario.id}"
  end

  def title_text
    @scenario.title.present? ? @scenario.title : ""
  end

  def wrapper_id
    "scenario-title-wrapper-#{@scenario.id}"
  end

  private

  attr_reader :scenario, :feature, :project
end

