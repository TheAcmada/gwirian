class CreateScenarioExecutions < ActiveRecord::Migration[8.0]
  def change
    create_table :scenario_executions do |t|
      t.references :scenario, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.text :notes
      t.datetime :executed_at, null: false

      t.timestamps
    end

    add_index :scenario_executions, [ :scenario_id, :executed_at ]
  end
end
