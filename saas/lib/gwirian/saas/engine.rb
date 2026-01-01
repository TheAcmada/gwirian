module Gwirian
  module Saas
    class Engine < ::Rails::Engine
      initializer "gwirian.saas.routes", after: :add_routing_paths do |app|
        # Routes that rely on the implicit account tenant should go here instead of in +routes.rb+.
        app.routes.prepend do
          namespace :account do
            resource :billing_portal, only: :show
            resource :subscription do
              scope module: :subscriptions do
                resource :upgrade, only: :create
                resource :downgrade, only: :create
              end
            end
          end
        end
      end

      initializer "gwirian.saas.mount" do |app|
        app.routes.append do
          mount Gwirian::Saas::Engine => "/", as: "saas"
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

      config.to_prepare do
      end
    end
  end
end
