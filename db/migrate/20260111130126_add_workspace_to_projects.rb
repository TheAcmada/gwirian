class AddWorkspaceToProjects < ActiveRecord::Migration[8.0]
  def change
    add_reference :projects, :workspace
  end
end
