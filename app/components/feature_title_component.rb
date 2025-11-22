class FeatureTitleComponent < ApplicationComponent
  def initialize(feature:, project:)
    @feature = feature
    @project = project
  end

  def update_path
    project_feature_path(@project, @feature)
  end

  def form_id
    "feature-title-form-#{@feature.id}"
  end

  def title_text
    @feature.title.present? ? @feature.title : ""
  end

  private

  attr_reader :feature, :project
end
