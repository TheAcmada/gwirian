module Scenarios
  class Component < ApplicationComponent
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

    def current_status
      @scenario.current_status
    end

    def latest_execution
      @scenario.latest_execution
    end

    def can_execute?
      helpers.can?(:execute, @scenario)
    end

    private

    attr_reader :scenario, :feature, :project
  end
end
