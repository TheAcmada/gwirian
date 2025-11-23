class ScenarioComponent < ApplicationComponent
  def initialize(scenario:, feature:, project:)
    @scenario = scenario
    @feature = feature
    @project = project
  end

  private

  attr_reader :scenario, :feature, :project
end
