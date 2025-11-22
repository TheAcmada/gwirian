class FeatureDescriptionComponent < ApplicationComponent
  def initialize(feature:, project:)
    @feature = feature
    @project = project
  end

  def update_path
    project_feature_path(@project, @feature)
  end

  def form_id
    "feature-description-form-#{@feature.id}"
  end

  def description_text
    @feature.description.present? ? @feature.description : ""
  end

  def has_description?
    @feature.description.present?
  end

  private

  attr_reader :feature, :project
end
