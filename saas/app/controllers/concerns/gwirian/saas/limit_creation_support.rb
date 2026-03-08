# frozen_string_literal: true

module Gwirian
  module Saas
    module LimitCreationSupport
      extend ActiveSupport::Concern

      private

      LIMIT_MESSAGES = {
        projects: [ "project", "create more projects" ],
        features: [ "feature", "create more features" ],
        scenarios: [ "scenario", "create more scenarios" ],
        members: [ "team member", "invite more members" ]
      }.freeze

      def ensure_under_plan_limit!(resource_type:, redirect_path:)
        return unless Current.workspace
        return if respond_to?(:current_user) && PlanLimitsBypass.gwirian_com?(current_user)

        method_name = :"exceeding_#{resource_type}_limit?"
        return unless Current.workspace.respond_to?(method_name) && Current.workspace.public_send(method_name)

        label, action = LIMIT_MESSAGES.fetch(resource_type)
        message = "You have reached the #{label} limit for your plan (#{Current.workspace.plan.name}). " \
                  "Please upgrade to #{action}."
        render_limit_reached(message: message, redirect_path: redirect_path)
      end

      def render_limit_reached(message:, redirect_path:)
        if request.format.json?
          render json: { error: message }, status: :forbidden
        elsif request.headers["HX-Request"]
          render html: "<div class='alert alert-danger'>#{message}</div>".html_safe, status: :forbidden
        else
          redirect_to redirect_path, alert: message
        end
      end
    end
  end
end
