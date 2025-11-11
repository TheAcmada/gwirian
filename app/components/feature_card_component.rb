class FeatureCardComponent < ApplicationComponent
  def initialize(feature:, project:)
    @feature = feature
    @project = project
  end

  private

  attr_reader :feature, :project
end
