class Project < ApplicationRecord
  belongs_to :workspace
  has_many :project_members, dependent: :destroy
  has_many :features, dependent: :destroy
  has_many :scenarios, through: :features
  has_many :scenario_executions, through: :scenarios

  validates :name, presence: true, length: { maximum: 80 }
  validates :description, length: { maximum: 1000 }
  validates :context, length: { maximum: 10_000 }, allow_blank: true

  # Returns the user's role in the project, or nil if not a member
  # This method is optimized to make a single query
  # @param [User] user
  # @return [String, nil] One of: "administrator", "editor", "viewer", or nil
  def user_role(user)
    return nil unless user
    @_user_roles ||= {}
    return @_user_roles[user.email_address] if @_user_roles.key?(user.email_address)

    member = project_members.find_by(email: user.email_address)
    role = member&.role
    @_user_roles[user.email_address] = role
    role
  end

  # Returns true if the user is an administrator of the project
  # @param [User] user
  # @return [Boolean]
  def admin?(user)
    user_role(user) == "administrator"
  end

  # Returns true if the user is an editor of the project
  # @param [User] user
  # @return [Boolean]
  def editor?(user)
    role = user_role(user)
    role == "editor" || role == "administrator"
  end

  # Returns true if the user is a viewer of the project
  # @param [User] user
  # @return [Boolean]
  def viewer?(user)
    role = user_role(user)
    %w[viewer editor administrator].include?(role)
  end

  # Returns true if the user is a member of the project
  # @param [User] user
  # @return [Boolean]
  def member?(user)
    user_role(user).present?
  end

  # Returns the full Gherkin for the whole project (project header + all features).
  def to_gherkin
    header = gherkin_project_header
    features_gherkin = features.includes(:scenarios, :taggings).order(:title).map(&:to_gherkin).join("\n\n")
    [ header, features_gherkin ].reject(&:blank?).join("\n\n")
  end

  # Returns an array of [ filename, content ] for building the BDD export ZIP.
  # First entry is project_info.md, then one .feature file per feature (slug from title, duplicates suffixed with id).
  def gherkin_export_entries
    entries = []
    entries << [ "project_info.md", gherkin_project_info_content ]
    features_list = features.includes(:scenarios, :taggings).order(:title).to_a
    used_basenames = {}
    features_list.each do |feature|
      base = feature.title.present? ? feature.title.parameterize : "feature"
      base = "feature" if base.blank?
      basename = base.dup
      if used_basenames[basename]
        n = used_basenames[basename]
        used_basenames[basename] = n + 1
        basename = "#{base}-#{n}"
      else
        used_basenames[basename] = 1
      end
      filename = "#{basename}.feature"
      entries << [ filename, feature.to_gherkin ]
    end
    entries
  end

  # Search within this project for features and scenarios matching the query (Elasticsearch).
  # @param [String] query search string
  # @param [Integer] limit max results per type (default 20)
  # @return [Array<Hash>] array of hashes with type, id, title, and type-specific fields
  def search_content(query, limit: 20)
    results = []
    return results if query.blank?

    features = Feature.search_by_project(query, id, limit: limit).records
                     .includes(scenarios: :scenario_executions)
    scenarios = Scenario.search_by_project(query, id, limit: limit).records
                       .includes(:feature, :scenario_executions)

    features.each do |f|
      statuses = f.scenarios.map(&:current_status)
      status = aggregate_status_from(statuses)
      results << {
        type: "feature", id: f.id, title: f.title,
        description: f.description, project_id: f.project_id,
        status: status
      }
    end

    scenarios.each do |s|
      results << {
        type: "scenario", id: s.id, title: s.title,
        feature_id: s.feature_id, feature_title: s.feature.title,
        status: s.current_status
      }
    end

    results
  end

  private

  def gherkin_project_header
    lines = []
    lines << "# Project: #{name}"
    lines << "# Description: #{description}" if description.present?
    if context.present?
      lines << "# Context (environments, URLs, etc.):"
      context.to_s.strip.split("\n").each { |line| lines << "# #{line.strip}" }
    end
    lines.join("\n")
  end

  def gherkin_project_info_content
    lines = []
    lines << "# #{name}"
    lines << ""
    if description.present?
      lines << "## Description"
      lines << ""
      lines << description.to_s.strip
      lines << ""
    end
    if context.present?
      lines << "## Context (environments, URLs, etc.)"
      lines << ""
      lines << "```"
      lines << context.to_s.strip
      lines << "```"
      lines << ""
    end
    lines.join("\n")
  end

  def aggregate_status_from(statuses)
    return nil if statuses.empty?
    return "failed" if statuses.include?("failed")
    return "pending" if statuses.include?("pending")
    "passed"
  end
end
