module Scenarios
  class TitleComponent < Shared::EditableComponent
    def initialize(scenario:, feature:, project:)
      @scenario = scenario
      @feature = feature
      @project = project
    end

    def update_path
      helpers.project_feature_scenario_path(@project, @feature, @scenario)
    end

    def field_name
      "title"
    end

    def resource_type
      "scenario"
    end

    def resource_id
      @scenario.id
    end

    def field_value
      @scenario.title.present? ? @scenario.title : ""
    end

    private

    attr_reader :scenario, :feature, :project
  end
end
