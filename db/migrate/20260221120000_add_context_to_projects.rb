# frozen_string_literal: true

class AddContextToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :context, :text
  end
end
