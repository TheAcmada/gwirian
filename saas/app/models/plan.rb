class Plan
  PLANS = {
    free: {
      key: "free",
      name: "Free",
      projects_limit: 1,
      features_limit: 5,
      scenarios_limit: 20,
      members_limit: 1
    },
    starter: {
      key: "starter",
      name: "Starter",
      projects_limit: 3,
      features_limit: 50,
      scenarios_limit: 200,
      members_limit: 3
    },
    professional: {
      key: "professional",
      name: "Professional",
      projects_limit: 10,
      features_limit: 200,
      scenarios_limit: 1000,
      members_limit: 10
    },
    team: {
      key: "team",
      name: "Team",
      projects_limit: Float::INFINITY,
      features_limit: Float::INFINITY,
      scenarios_limit: Float::INFINITY,
      members_limit: 25
    }
  }

  attr_reader :key, :name, :projects_limit, :features_limit, :scenarios_limit, :members_limit

  class << self
    def all
      @all ||= PLANS.map { |key, properties| new(key: key, **properties) }
    end

    def free
      @free ||= find(:free)
    end

    def find(key)
      @all_by_key ||= all.index_by(&:key).with_indifferent_access
      @all_by_key[key]
    end

    alias [] find
  end

  def initialize(key:, name:, projects_limit:, features_limit:, scenarios_limit:, members_limit:)
    @key = key
    @name = name
    @projects_limit = projects_limit
    @features_limit = features_limit
    @scenarios_limit = scenarios_limit
    @members_limit = members_limit
  end

  def free?
    key == "free"
  end

  def paid?
    !free?
  end

  def limit_projects?
    !projects_limit.infinite?
  end

  def limit_features?
    !features_limit.infinite?
  end

  def limit_scenarios?
    !scenarios_limit.infinite?
  end
end
