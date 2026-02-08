class CreateMagicLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :magic_links do |t|
      t.string :code, null: false
      t.references :user, null: false, foreign_key: true
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :magic_links, :code, unique: true
    add_index :magic_links, :expires_at
  end
end
