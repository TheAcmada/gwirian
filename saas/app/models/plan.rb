class Plan
  PLANS = {
    "free" => {
      key: "free",
      name: "Free",
      projects_limit: 1,
      features_limit: 5,
      scenarios_limit: 20,
      members_limit: 3
    },
    "starter" => {
      key: "starter",
      name: "Starter",
      projects_limit: 3,
      features_limit: 50,
      scenarios_limit: 200,
      members_limit: 3
    },
    "professional" => {
      key: "professional",
      name: "Professional",
      projects_limit: 10,
      features_limit: 200,
      scenarios_limit: 1000,
      members_limit: 10
    },
    "team" => {
      key: "team",
      name: "Team",
      projects_limit: Float::INFINITY,
      features_limit: Float::INFINITY,
      scenarios_limit: Float::INFINITY,
      members_limit: 25
    }
  }.freeze

  PADDLE_PRICE_ENV_KEYS = {
    "starter" => "PADDLE_PRICE_STARTER",
    "professional" => "PADDLE_PRICE_PROFESSIONAL",
    "team" => "PADDLE_PRICE_TEAM"
  }.freeze

  attr_reader :key, :name, :projects_limit, :features_limit, :scenarios_limit, :members_limit, :paddle_price_id

  class << self
    def all
      @all ||= PLANS.map { |plan_key, properties| new(paddle_price_id: paddle_price_id_for(plan_key), **properties) }
    end

    def free
      @free ||= find("free")
    end

    def find(key)
      return nil if key.blank?
      @all_by_key ||= all.index_by(&:key)
      @all_by_key[key.to_s]
    end

    def find_by_paddle_price_id(price_id)
      return nil if price_id.blank?
      all.find { |p| p.paddle_price_id == price_id }
    end

    def paddle_price_id_for(plan_key)
      env_key = PADDLE_PRICE_ENV_KEYS[plan_key.to_s]
      env_key ? ENV[env_key].to_s.presence : nil
    end
  end

  def initialize(key:, name:, projects_limit:, features_limit:, scenarios_limit:, members_limit:, paddle_price_id: nil)
    @key = key
    @name = name
    @projects_limit = projects_limit
    @features_limit = features_limit
    @scenarios_limit = scenarios_limit
    @members_limit = members_limit
    @paddle_price_id = paddle_price_id
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

  def limit_members?
    !members_limit.infinite?
  end
end
