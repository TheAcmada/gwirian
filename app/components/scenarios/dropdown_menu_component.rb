module Scenarios
  class DropdownMenuComponent < Shared::DropdownMenuComponent
    def initialize(scenario:, feature:, project:)
      @scenario = scenario
      @feature = feature
      @project = project
    end

    def delete_path
      helpers.project_feature_scenario_path(@project, @feature, @scenario)
    end

    def delete_target
      "closest .scenario-item"
    end

    def confirmation_message
      "Are you sure you want to delete this scenario?"
    end

    private

    attr_reader :scenario, :feature, :project
  end
end
