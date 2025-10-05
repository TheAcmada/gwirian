class CreateProjectMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :project_members do |t|
      t.references :project, null: false, foreign_key: true
      t.string :email, null: false
      t.string :role, null: false, default: 'guest'
      t.boolean :invitation_accepted, null: false, default: false
      t.string :project_members, :invitation_token
      t.datetime :last_invitation_sent_at

      t.timestamps
    end
    add_index :project_members, [ :project_id, :email ], unique: true
    add_index :project_members, :email
    add_index :project_members, :invitation_token, unique: true
  end
end
