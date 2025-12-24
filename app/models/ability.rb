# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the user here. For example:
    #
    #   return unless user.present?
    #   can :read, :all
    #   return unless user.admin?
    #   can :manage, :all
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, published: true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md

    return unless user.present?

    initialize_project_ability(user)
    initialize_feature_ability(user)
    initialize_scenario_ability(user)
    initialize_scenario_execution_ability(user)
    initialize_step_ability(user)
  end

  def initialize_project_ability(user)
    can :create, Project

    can :read, Project do |project|
      project.member?(user)
    end

    can [ :update, :destroy, :add_member ], Project do |project|
      project.admin?(user)
    end

    can [ :remove, :update, :invite ], ProjectMember do |member|
      member.project.admin?(user) && member.email != user.email_address
    end
  end

  def initialize_feature_ability(user)
    can :read, Feature do |feature|
      feature.project.member?(user)
    end

    can :create, Feature do |feature|
      feature.project.editor?(user) || feature.project.admin?(user)
    end

    can [ :update, :destroy ], Feature do |feature|
      feature.project.editor?(user) || feature.project.admin?(user)
    end

    can :execute, Feature do |feature|
      feature.project.editor?(user) || feature.project.admin?(user)
    end
  end

  def initialize_scenario_ability(user)
    can :read, Scenario do |scenario|
      scenario.feature.project.member?(user)
    end

    can :create, Scenario do |scenario|
      scenario.feature.project.editor?(user) || scenario.feature.project.admin?(user)
    end

    can [ :update, :destroy ], Scenario do |scenario|
      scenario.feature.project.editor?(user) || scenario.feature.project.admin?(user)
    end

    can :execute, Scenario do |scenario|
      scenario.feature.project.editor?(user) || scenario.feature.project.admin?(user)
    end
  end

  def initialize_scenario_execution_ability(user)
    can :read, ScenarioExecution do |execution|
      execution.scenario.feature.project.member?(user)
    end

    can [ :create, :update, :destroy ], ScenarioExecution do |execution|
      execution.scenario.feature.project.editor?(user) || execution.scenario.feature.project.admin?(user)
    end
  end

  def initialize_step_ability(user)
    can :create, Step do |step|
      step.scenario.feature.project.editor?(user) || step.scenario.feature.project.admin?(user)
    end

    can [ :update, :destroy ], Step do |step|
      step.scenario.feature.project.editor?(user) || step.scenario.feature.project.admin?(user)
    end
  end
end
