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

  # Returns the Gherkin content for this feature (tags, Feature:, description, Background, scenarios).
  def to_gherkin
    lines = []
    lines << tag_list.map { |t| "@#{t}" }.join(" ") if tag_list.present?
    lines << "Feature: #{gherkin_escape_line(title)}"
    if description.present?
      gherkin_escape_description(description).each { |line| lines << "  #{line}" }
      lines << ""
    end
    if background.present?
      lines << "  Background:"
      gherkin_escape_description(background).each { |line| lines << "    Given #{line}" }
      lines << ""
    end
    scenarios.each do |scenario|
      scenario.to_gherkin.split("\n").each { |sline| lines << "  #{sline}" }
      lines << ""
    end
    lines.pop if lines.last == ""
    lines.join("\n")
  end

  private

  def gherkin_escape_line(text)
    return "" if text.blank?
    text.to_s.strip.gsub(/\r\n|\r/, "\n")
  end

  def gherkin_escape_description(text)
    return [] if text.blank?
    text.to_s.gsub(/\r\n|\r/, "\n").strip.split("\n").map(&:strip).reject(&:blank?)
  end

  public

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
