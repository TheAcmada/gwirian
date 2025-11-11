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
end
