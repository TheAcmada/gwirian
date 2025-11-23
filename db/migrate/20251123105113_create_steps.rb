class CreateSteps < ActiveRecord::Migration[8.0]
  def change
    create_table :steps do |t|
      t.references :scenario, null: false, foreign_key: true
      t.text :action
      t.timestamps
    end
  end
end
