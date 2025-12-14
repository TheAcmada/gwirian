module Steps
  class Component < ApplicationComponent
    def initialize(step:, scenario:, feature:, project:)
      @step = step
      @scenario = scenario
      @feature = feature
      @project = project
    end

    def update_path
      helpers.project_feature_scenario_step_path(@project, @feature, @scenario, @step)
    end

    def form_id
      "step-form-#{@step.id}"
    end

    def wrapper_id
      "step-wrapper-#{@step.id}"
    end

    def action_text
      @step.action.presence || ""
    end

    private

    attr_reader :step, :scenario, :feature, :project
  end
end
