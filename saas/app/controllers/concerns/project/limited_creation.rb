module Project::LimitedCreation
  extend ActiveSupport::Concern
  include Gwirian::Saas::LimitCreationSupport

  included do
    before_action :ensure_under_projects_limit, only: %i[ create ]
  end

  private

  def ensure_under_projects_limit
    ensure_under_plan_limit!(resource_type: :projects, redirect_path: projects_path)
  end
end
