class RemoveApiTokenFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_index :users, :api_token, if_exists: true
    remove_column :users, :api_token, :string
    remove_column :users, :api_token_expires_at, :datetime
  end
end
