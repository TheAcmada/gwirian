class Feature < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ElasticsearchQuerySanitizer

  belongs_to :project
  has_many :scenarios, -> { order(:position) }, dependent: :destroy
  has_many :scenario_executions, through: :scenarios
  acts_as_taggable_on :tags

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 1000 }, allow_blank: true

  settings index: { number_of_shards: 1 } do
    mappings dynamic: "false" do
      indexes :title, type: "text", analyzer: "english"
      indexes :description, type: "text", analyzer: "english"
      indexes :tags, type: "text", analyzer: "standard" do
        indexes :keyword, type: "keyword"
      end
      indexes :project_id, type: "integer"
    end
  end

  def as_indexed_json(options = {})
    {
      title: title,
      description: description,
      tags: tag_list,
      project_id: project_id
    }
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
                fields: [ "title^3", "description^2", "tags" ],
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
end
