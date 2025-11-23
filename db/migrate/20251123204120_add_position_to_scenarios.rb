class AddPositionToScenarios < ActiveRecord::Migration[8.0]
  def change
    add_column :scenarios, :position, :integer
  end
end
