class CreateLoginHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :login_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.text :user_agent

      t.timestamps
    end
  end
end
