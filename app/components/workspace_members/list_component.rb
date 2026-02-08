# frozen_string_literal: true

module WorkspaceMembers
  class ListComponent < ApplicationComponent
    def initialize(workspace:, current_user:, notice: nil, alert: nil)
      @workspace = workspace
      @current_user = current_user
      @notice = notice
      @alert = alert
    end

    # Public methods for use in partials
    def member_email(member)
      member.user.email_address
    end

    def member_avatar_letter(member)
      member_email(member).first.upcase
    end

    def member_status(member)
      member.current_member? ? "Active" : "Pending"
    end

    def member_status_class(member)
      member.current_member? ? "bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-400" : "bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-400"
    end

    def can_update?(member)
      workspace.admin?(current_user) && member.user_id != current_user.id
    end

    def can_remove?(member)
      workspace.admin?(current_user) && member.user_id != current_user.id
    end

    def can_resend?(member)
      member.invited? && can_update?(member)
    end

    def members
      @members ||= workspace.workspace_members.includes(:user).joins(:user).order("users.email_address ASC")
    end

    private

    attr_reader :workspace, :current_user, :notice, :alert
  end
end
