module WorkspaceSlug
  class Extractor
    EXCLUDED_PATHS = %w[
      /session
      /up
      /mcp
      /api
      /rails
      /assets
      /project_members
    ].freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      path = env["PATH_INFO"]

      # Skip extraction for excluded paths
      if excluded_path?(path)
        return @app.call(env)
      end

      # Extract workspace slug from first path segment
      slug, remaining_path = extract_slug(path)

      if slug.present?
        workspace = Workspace.find_by(slug: slug)

        if workspace
          Current.workspace = workspace

          # Rewrite paths for Rails routing
          env["SCRIPT_NAME"] = "#{env['SCRIPT_NAME']}/#{slug}"
          env["PATH_INFO"] = remaining_path.presence || "/"
        end
      end

      @app.call(env)
    end

    private

    def excluded_path?(path)
      EXCLUDED_PATHS.any? { |excluded| path.start_with?(excluded) }
    end

    def extract_slug(path)
      # Match /:slug or /:slug/...
      match = path.match(%r{\A/([a-z0-9]+(?:-[a-z0-9]+)*)(/.*)?}i)
      return [ nil, path ] unless match

      slug = match[1].downcase
      remaining = match[2]

      [ slug, remaining ]
    end
  end
end
