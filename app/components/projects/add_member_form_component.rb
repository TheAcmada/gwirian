# frozen_string_literal: true

module Projects
  class AddMemberFormComponent < ApplicationComponent
    def initialize(project:)
      @project = project
    end

    def available_members
      @available_members ||= begin
        existing_emails = project.project_members.pluck(:email)
        Current.workspace.workspace_members
          .current_member
          .includes(:user)
          .reject { |wm| existing_emails.include?(wm.user.email_address) }
          .map { |wm| { email: wm.user.email_address } }
      end
    end

    def available_members_json
      available_members.to_json
    end

    def can_add_member?
      helpers.can?(:add_member, project)
    end

    private

    attr_reader :project
  end
end
