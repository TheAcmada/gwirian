module Workspaces
  class OptionsComponent < ApplicationComponent
    def initialize(workspace: nil)
      @workspace = workspace || Workspace.new
    end

    private

    attr_reader :workspace

    def pending_invitations
      @pending_invitations ||= Current.user&.pending_workspace_invitations || []
    end

    def left_workspaces
      @left_workspaces ||= Current.user&.left_workspaces || []
    end

    def has_join_options?
      pending_invitations.any? || left_workspaces.any?
    end
  end
end
