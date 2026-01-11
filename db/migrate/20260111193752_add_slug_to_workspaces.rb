class AddSlugToWorkspaces < ActiveRecord::Migration[8.0]
  def up
    add_column :workspaces, :slug, :string
    add_index :workspaces, :slug, unique: true

    # Populate existing workspaces with slugs based on name
    Workspace.reset_column_information
    Workspace.find_each do |workspace|
      base_slug = workspace.name.parameterize
      slug = base_slug
      counter = 1
      while Workspace.where(slug: slug).where.not(id: workspace.id).exists?
        slug = "#{base_slug}-#{counter}"
        counter += 1
      end
      workspace.update_column(:slug, slug)
    end

    change_column_null :workspaces, :slug, false
  end

  def down
    remove_column :workspaces, :slug
  end
end
