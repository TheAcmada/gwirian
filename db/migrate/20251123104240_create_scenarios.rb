class CreateScenarios < ActiveRecord::Migration[8.0]
  def change
    create_table :scenarios do |t|
      t.references :feature, null: false, foreign_key: true
      t.string :title
      t.text :given
      t.text :when
      t.text :then
      t.timestamps
    end
  end
end
