class AddInvitationTokenExpiresAtToProjectMembers < ActiveRecord::Migration[8.0]
  def change
    add_column :project_members, :invitation_token_expires_at, :datetime
  end
end
