class Plan
  PLANS = {
    "free" => {
      key: "free",
      name: "Free",
      price: "$0",
      price_label: "forever",
      description: "For individuals getting started",
      highlighted: false,
      projects_limit: 1,
      features_limit: 5,
      scenarios_limit: 20,
      members_limit: 3
    },
    "starter" => {
      key: "starter",
      name: "Starter",
      price: "$19",
      price_label: "/month",
      description: "For small teams and side projects",
      highlighted: false,
      projects_limit: 3,
      features_limit: 50,
      scenarios_limit: 200,
      members_limit: 3
    },
    "professional" => {
      key: "professional",
      name: "Professional",
      price: "$49",
      price_label: "/month",
      description: "For growing teams with complex workflows",
      highlighted: true,
      projects_limit: 10,
      features_limit: 200,
      scenarios_limit: 1000,
      members_limit: 10
    },
    "team" => {
      key: "team",
      name: "Team",
      price: "$99",
      price_label: "/month",
      description: "For organizations at scale",
      highlighted: false,
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

  attr_reader :key, :name, :price, :price_label, :description, :projects_limit, :features_limit, :scenarios_limit, :members_limit, :paddle_price_id

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

  def initialize(key:, name:, projects_limit:, features_limit:, scenarios_limit:, members_limit:, paddle_price_id: nil, price: "$0", price_label: "", description: "", highlighted: false)
    @key = key
    @name = name
    @price = price
    @price_label = price_label
    @description = description
    @highlighted = highlighted
    @projects_limit = projects_limit
    @features_limit = features_limit
    @scenarios_limit = scenarios_limit
    @members_limit = members_limit
    @paddle_price_id = paddle_price_id
  end

  def free?
    key == "free"
  end

  def highlighted?
    @highlighted
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
