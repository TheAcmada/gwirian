class CreateTestCases < ActiveRecord::Migration[8.0]
  def change
    create_table :test_cases do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.text :preconditions
      t.text :expected_result, null: false
      t.string :priority, default: "medium"
      t.string :status, default: "draft"
      t.string :category

      t.timestamps
    end
  end
end
