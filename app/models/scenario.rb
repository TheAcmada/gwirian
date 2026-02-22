class Scenario < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ElasticsearchQuerySanitizer

  belongs_to :feature
  has_many :steps, -> { order(:position) }, dependent: :destroy
  has_many :scenario_executions, dependent: :destroy
  acts_as_list scope: :feature
  validates :title, presence: true, length: { maximum: 255 }

  settings index: { number_of_shards: 1 } do
    mappings dynamic: "false" do
      indexes :title, type: "text", analyzer: "english"
      indexes :given, type: "text", analyzer: "english"
      indexes :when, type: "text", analyzer: "english"
      indexes :then, type: "text", analyzer: "english"
      indexes :feature_id, type: "integer"
      indexes :project_id, type: "integer"
    end
  end

  def as_indexed_json(options = {})
    {
      title: title,
      given: given,
      when: self.when,
      then: self.then,
      feature_id: feature_id,
      project_id: feature&.project_id
    }
  end

  def latest_execution
    if scenario_executions.loaded?
      scenario_executions.max_by(&:executed_at)
    else
      scenario_executions.latest_first.first
    end
  end

  def current_status
    latest_execution&.status || "pending"
  end

  def execution_count
    scenario_executions.count
  end

  def self.search_by_project(query, project_id, limit: 100)
    sanitized_query = sanitize_elasticsearch_query(query)
    search({
      size: [ limit, 1000 ].min, # Cap at 1000 to prevent DoS
      query: {
        bool: {
          must: [
            {
              query_string: {
                query: sanitized_query,
                fields: [ "title^3", "given^2", "when^2", "then^2" ],
                fuzziness: "AUTO",
                default_operator: "AND",
                escape: true
              }
            },
            {
              term: { project_id: project_id }
            }
          ]
        }
      }
    })
  end

  def self.search_by_feature(query, feature_id, limit: 100)
    sanitized_query = sanitize_elasticsearch_query(query)
    search({
      size: [ limit, 1000 ].min,
      query: {
        bool: {
          must: [
            {
              query_string: {
                query: sanitized_query,
                fields: [ "title^3", "given^2", "when^2", "then^2" ],
                fuzziness: "AUTO",
                default_operator: "AND",
                escape: true
              }
            },
            {
              term: { feature_id: feature_id }
            }
          ]
        }
      }
    })
  end
end
