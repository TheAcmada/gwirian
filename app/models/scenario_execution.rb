class ScenarioExecution < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :scenario
  belongs_to :user

  STATUSES = %w[pending passed failed].freeze

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :executed_at, presence: true

  scope :latest_first, -> { order(executed_at: :desc) }
  scope :pending, -> { where(status: "pending") }
  scope :passed, -> { where(status: "passed") }
  scope :failed, -> { where(status: "failed") }

  settings index: { number_of_shards: 1 } do
    mappings dynamic: "false" do
      indexes :feature_title, type: "text", analyzer: "english"
      indexes :scenario_title, type: "text", analyzer: "english"
      indexes :user_email, type: "text", analyzer: "standard"
      indexes :status, type: "keyword"
      indexes :notes, type: "text", analyzer: "english"
      indexes :executed_at, type: "date"
      indexes :project_id, type: "integer"
    end
  end

  def as_indexed_json(options = {})
    {
      feature_title: scenario&.feature&.title,
      scenario_title: scenario&.title,
      user_email: user&.email_address,
      status: status,
      notes: notes,
      executed_at: executed_at,
      project_id: scenario&.feature&.project_id
    }
  end

  def self.search_by_project(query, project_id)
    search({
      size: 1000,
      query: {
        bool: {
          must: [
            {
              query_string: {
                query: query,
                fields: [ "feature_title^3", "scenario_title^2", "user_email", "status", "notes" ],
                fuzziness: "AUTO",
                default_operator: "AND"
              }
            },
            {
              term: { project_id: project_id }
            }
          ]
        }
      },
      sort: [
        { executed_at: { order: "desc" } }
      ]
    })
  end

  def pending?
    status == "pending"
  end

  def passed?
    status == "passed"
  end

  def failed?
    status == "failed"
  end
end
