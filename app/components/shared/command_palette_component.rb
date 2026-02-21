# frozen_string_literal: true

module Shared
  class CommandPaletteComponent < ApplicationComponent
    def initialize(workspace:, project: nil, prev_feature: nil, next_feature: nil)
      @workspace = workspace
      @project = project
      @prev_feature = prev_feature
      @next_feature = next_feature
    end

    def render?
      @workspace.present?
    end

    def search_url
      return nil unless @project.present? && @project.persisted?

      search_project_path(@project, format: :json)
    end

    def static_items
      items = []
      projects = helpers.workspace_projects.order(:name)
      user_workspaces = Current.user&.workspace_members&.current_member&.includes(:workspace) || []

      if @project.present? && @project.persisted?
        if helpers.can?(:create, @project.features.build)
          items << { type: "command", title: "Create new feature", subtitle: "Command", url: project_features_path(@project), method: "post", keywords: "new feature create" }
        end
        items << { type: "nav", title: "Dashboard", subtitle: "Project", url: project_path(@project), keywords: "dashboard project", shortcut: "G D" }
        items << { type: "nav", title: "Features", subtitle: "Project", url: project_features_path(@project), keywords: "features list", shortcut: "G F" }
        items << { type: "nav", title: "History", subtitle: "Project", url: history_project_path(@project), keywords: "history executions", shortcut: "G H" }
        items << { type: "nav", title: "Project settings", subtitle: "Members, settings", url: edit_project_path(@project), keywords: "settings members edit", shortcut: "G S" }
        if @prev_feature.present?
          items << { type: "nav", title: "Previous feature", subtitle: "Project", url: project_feature_path(@project, @prev_feature), keywords: "previous feature", shortcut: "G P" }
        end
        if @next_feature.present?
          items << { type: "nav", title: "Next feature", subtitle: "Project", url: project_feature_path(@project, @next_feature), keywords: "next feature", shortcut: "G N" }
        end
        projects.each do |p|
          next if p.id == @project.id
          items << { type: "nav", title: "Go to #{p.name}", subtitle: "Project", url: project_path(p), keywords: "project #{p.name}" }
        end
      else
        projects.each do |p|
          items << { type: "nav", title: "Go to #{p.name}", subtitle: "Project", url: project_path(p), keywords: "project #{p.name}" }
        end
      end

      if helpers.can?(:create, Project)
        items << { type: "nav", title: "New project", subtitle: "Create", url: new_project_path, keywords: "new project create" }
      end
      if @workspace&.admin?(Current.user)
        items << { type: "nav", title: "Invite and manage members", subtitle: "Workspace", url: workspace_members_path, keywords: "invite members workspace" }
      end
      user_workspaces.each do |membership|
        ws = membership.workspace
        next unless ws
        items << { type: "nav", title: "Switch to #{ws.name}", subtitle: "Workspace", url: "/#{ws.slug}/projects", keywords: "workspace switch #{ws.name}" }
      end
      if Current.user.present?
        items << { type: "nav", title: "Account", subtitle: "Profile", url: edit_user_path(Current.user), keywords: "account profile user" }
      end

      items
    end

    def shortcuts
      list = []
      modifier = helpers.shortcut_modifier
      list << { keys: "#{modifier}K", label: "Search" }
      list << { keys: "?", label: "Keyboard shortcuts" }
      if @project.present? && @project.persisted?
        list << { keys: "G D", label: "Dashboard" }
        list << { keys: "G F", label: "Features" }
        list << { keys: "G H", label: "History" }
        list << { keys: "G S", label: "Settings" }
      end
      list << { keys: "G P", label: "Previous feature" } if @prev_feature.present?
      list << { keys: "G N", label: "Next feature" } if @next_feature.present?
      list
    end

    def meta_shortcuts
      modifier = helpers.shortcut_modifier
      [
        { keys: "#{modifier}K", label: "Search" },
        { keys: "?", label: "Keyboard shortcuts" }
      ]
    end

    def config_json
      {
        searchUrl: search_url,
        staticItems: static_items,
        csrfToken: helpers.form_authenticity_token,
        shortcuts: shortcuts,
        metaShortcuts: meta_shortcuts
      }.to_json
    end

    def placeholder
      if @project.present? && @project.persisted?
        "Search or run a command..."
      else
        "Type to filter actions and go to..."
      end
    end
  end
end
