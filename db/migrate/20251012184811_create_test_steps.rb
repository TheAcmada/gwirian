class CreateTestSteps < ActiveRecord::Migration[8.0]
  def change
    create_table :test_steps do |t|
      t.references :test_case, null: false, foreign_key: true
      t.integer :position, null: false
      t.text :action, null: false
      t.text :expected_result

      t.timestamps
    end
  end
end
