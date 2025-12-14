class ScenarioComponent < ApplicationComponent
  def initialize(scenario:, feature:, project:)
    @scenario = scenario
    @feature = feature
    @project = project
  end

  def update_path
    helpers.project_feature_scenario_path(@project, @feature, @scenario)
  end

  def form_id
    "scenario-details-form-#{@scenario.id}"
  end

  def wrapper_id
    "scenario-wrapper-#{@scenario.id}"
  end

  def given_text
    @scenario.given.presence || ""
  end

  def when_text
    @scenario[:when].presence || ""
  end

  def then_text
    @scenario[:then].presence || ""
  end

  private

  attr_reader :scenario, :feature, :project
end
