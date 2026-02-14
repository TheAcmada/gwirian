# frozen_string_literal: true

module ProjectAccessible
  extend ActiveSupport::Concern

  private

  def accessible_projects
    return Project.none unless Current.workspace && current_user

    Current.workspace.projects
      .joins(:project_members)
      .where(project_members: { email: current_user.email_address })
      .distinct
  end
end
