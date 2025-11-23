class AddBackgroundToFeatures < ActiveRecord::Migration[8.0]
  def change
    add_column :features, :background, :text
  end
end
