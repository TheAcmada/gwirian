class RemoveInvitationFieldsFromProjectMembers < ActiveRecord::Migration[8.0]
  def change
    remove_index :project_members, :invitation_token
    remove_index :project_members, :invitation_token_expires_at

    remove_column :project_members, :invitation_accepted, :boolean
    remove_column :project_members, :invitation_token, :string
    remove_column :project_members, :invitation_token_expires_at, :datetime
    remove_column :project_members, :last_invitation_sent_at, :datetime
    remove_column :project_members, :project_members, :string  # unused column
  end
end
