class AddApiTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :api_token, :string
    add_column :users, :api_token_expires_at, :datetime
    add_index :users, :api_token, unique: true
  end
end
