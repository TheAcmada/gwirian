module Scenarios
  class AddScenarioLinkComponent < ApplicationComponent
    def initialize(project:, feature:)
      @project = project
      @feature = feature
    end

    def scenarios_path
      helpers.project_feature_scenarios_path(project, feature)
    end

    private

    attr_reader :project, :feature
  end
end
