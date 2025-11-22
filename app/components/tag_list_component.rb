class TagListComponent < ApplicationComponent
  def initialize(taggable: nil, tags: nil, css_class: "mt-3", project: nil)
    @taggable = taggable
    @tags = tags || (taggable&.tags)
    @css_class = css_class
    @project = project || taggable&.project
  end

  def tag_list_string
    return "" unless tags&.any?
    tags.map(&:name).join(", ")
  end

  def update_path
    return nil unless taggable && @project
    project_feature_path(@project, taggable)
  end

  def form_id
    return nil unless taggable
    "feature-form-#{taggable.id}"
  end

  private

  attr_reader :taggable, :tags, :css_class, :project
end

