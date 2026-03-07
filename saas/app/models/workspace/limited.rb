module Workspace::Limited
  extend ActiveSupport::Concern

  def plan
    @plan ||= Plan.find(workspace_subscription&.plan_key || "free") || Plan.free
  end

  def workspace_subscription
    @workspace_subscription ||= WorkspaceSubscription.find_by(workspace_id: id)
  end

  def projects_count
    projects.count
  end

  def features_count
    Feature.joins(:project).where(projects: { workspace_id: id }).count
  end

  def scenarios_count
    Scenario.joins(feature: :project).where(projects: { workspace_id: id }).count
  end

  def members_count
    workspace_members.current_member.count
  end

  def can_create_project?
    return true unless plan.limit_projects?
    projects_count < plan.projects_limit
  end

  def can_create_feature?
    return true unless plan.limit_features?
    features_count < plan.features_limit
  end

  def can_create_scenario?
    return true unless plan.limit_scenarios?
    scenarios_count < plan.scenarios_limit
  end

  def can_add_member?
    return true unless plan.limit_members?
    members_count < plan.members_limit
  end

  def exceeding_projects_limit?
    plan.limit_projects? && projects_count >= plan.projects_limit
  end

  def exceeding_features_limit?
    plan.limit_features? && features_count >= plan.features_limit
  end

  def exceeding_scenarios_limit?
    plan.limit_scenarios? && scenarios_count >= plan.scenarios_limit
  end

  def exceeding_members_limit?
    plan.limit_members? && members_count >= plan.members_limit
  end

  def exceeding_limits?
    exceeding_projects_limit? || exceeding_features_limit? || exceeding_scenarios_limit? || exceeding_members_limit?
  end
end
