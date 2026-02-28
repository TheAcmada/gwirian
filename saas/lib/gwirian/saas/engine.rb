require_relative "../../rails_ext/active_record_tasks_database_tasks"

module Gwirian
  module Saas
    class Engine < ::Rails::Engine
      initializer "gwirian.saas.routes", after: :add_routing_paths do |app|
        app.routes.prepend do
          post "paddle/webhooks", to: "paddle/webhooks#create"
        end
      end

      initializer "gwirian.saas.mount" do |app|
        app.routes.append do
          mount Gwirian::Saas::Engine => "/", as: "saas"

          resource :subscription, only: [ :show, :create ] do
            post :cancel
            post :resume
            get :portal
          end
        end
      end

      initializer "gwirian.saas.sentry" do
        if !Rails.env.local? && ENV["SKIP_TELEMETRY"].blank?
          Sentry.init do |config|
            config.dsn = ENV["SENTRY_DSN"]
            config.breadcrumbs_logger = %i[ active_support_logger http_logger ]
            config.send_default_pii = false
            config.release = ENV["KAMAL_VERSION"]
          end
        end
      end

      initializer "gwirian.saas.log_mode" do
        Rails.logger.info "Gwirian SaaS mode enabled - Plan limits are active"
      end

      config.to_prepare do
        require_relative "plan_limits_bypass"
        require_relative "mcp_tools_limited_creation"

        ::Workspace.include Workspace::Limited
        ::ProjectsController.include Project::LimitedCreation
        ::FeaturesController.include Feature::LimitedCreation
        ::ScenariosController.include Scenario::LimitedCreation
        ::WorkspaceMembersController.include WorkspaceMember::LimitedCreation
        # API controllers
        ::Api::V1::FeaturesController.include Feature::LimitedCreation
        ::Api::V1::ScenariosController.include Scenario::LimitedCreation
        # MCP tools: enforce plan limits when creating features/scenarios via MCP
        ::Mcp::Tools::CreateFeature.singleton_class.prepend(Feature::LimitedMcpCreation)
        ::Mcp::Tools::CreateScenario.singleton_class.prepend(Scenario::LimitedMcpCreation)
      end
    end
  end
end
