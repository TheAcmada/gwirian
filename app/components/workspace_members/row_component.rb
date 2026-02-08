# frozen_string_literal: true

module WorkspaceMembers
  class RowComponent < ApplicationComponent
    def initialize(member:, workspace:, list_component:)
      @member = member
      @workspace = workspace
      @list_component = list_component
    end

    private

    attr_reader :member, :workspace, :list_component

    def member_email
      list_component.member_email(member)
    end

    def member_avatar_letter
      list_component.member_avatar_letter(member)
    end

    def member_status
      list_component.member_status(member)
    end

    def member_status_class
      list_component.member_status_class(member)
    end

    def can_update?
      list_component.can_update?(member)
    end

    def can_remove?
      list_component.can_remove?(member)
    end

    def can_resend?
      list_component.can_resend?(member)
    end
  end
end
