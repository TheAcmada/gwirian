# frozen_string_literal: true

class AddPerformanceIndexesForScenarioExecutionsAndScenarios < ActiveRecord::Migration[8.0]
  def change
    add_index :scenario_executions, :executed_at, name: "index_scenario_executions_on_executed_at"
    add_index :scenario_executions, :status, name: "index_scenario_executions_on_status"
    add_index :scenarios, [ :feature_id, :position ], name: "index_scenarios_on_feature_id_and_position"
  end
end
