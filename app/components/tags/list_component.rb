module Tags
  class ListComponent < ApplicationComponent
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
      helpers.project_feature_path(@project, taggable)
    end

    def form_id
      return nil unless taggable
      "feature-tag-list-form-#{taggable.id}"
    end

    def add_tag_path
      return nil unless taggable && @project
      helpers.add_tag_project_feature_path(@project, taggable)
    end

    def remove_tag_path(tag_name)
      return nil unless taggable && @project
      helpers.remove_tag_project_feature_path(@project, taggable)
    end

    def can_edit?
      update_path.present?
    end

    def tag_color_class(tag)
      # Deterministically assign a color based on tag name hash
      # This ensures the same tag always gets the same color
      color_index = tag.name.hash.abs % 8 + 1
      "badge-tag-#{color_index}"
    end

    private

    attr_reader :taggable, :tags, :css_class, :project
  end
end
