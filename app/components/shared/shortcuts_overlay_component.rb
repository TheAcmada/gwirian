# frozen_string_literal: true

module Shared
  class ShortcutsOverlayComponent < ApplicationComponent
    def initialize(workspace:, project: nil, prev_feature: nil, next_feature: nil)
      @workspace = workspace
      @project = project
      @prev_feature = prev_feature
      @next_feature = next_feature
    end

    def render?
      @workspace.present?
    end

    def modifier
      helpers.shortcut_modifier
    end

    def shortcuts
      list = []
      list << { keys: "#{modifier}K", label: "Search" }
      list << { keys: "?", label: "Keyboard shortcuts" }
      if @project.present? && @project.persisted?
        list << { keys: "G D", label: "Dashboard" }
        list << { keys: "G F", label: "Features" }
        list << { keys: "G H", label: "History" }
        list << { keys: "G S", label: "Settings" }
        list << { keys: "G P", label: "Previous feature" } if @prev_feature.present?
        list << { keys: "G N", label: "Next feature" } if @next_feature.present?
      end
      list
    end
  end
end
