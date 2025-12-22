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

    def status_color
      case current_status
      when "passed"
        "text-green-600 dark:text-green-400"
      when "failed"
        "text-red-600 dark:text-red-400"
      else
        "text-zinc-400 dark:text-gray-500"
      end
    end

    def status_icon
      case current_status
      when "passed"
        '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>'
      when "failed"
        '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>'
      else
        '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>'
      end
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
