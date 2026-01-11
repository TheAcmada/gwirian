require_relative "../../lib/workspace_slug/extractor"

Rails.application.config.middleware.use WorkspaceSlug::Extractor
