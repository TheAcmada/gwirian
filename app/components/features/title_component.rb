module Features
  class TitleComponent < Shared::EditableComponent
    def initialize(feature:, project:)
      @feature = feature
      @project = project
    end

    def update_path
      helpers.project_feature_path(@project, @feature)
    end

    def field_name
      "title"
    end

    def resource_type
      "feature"
    end

    def resource_id
      @feature.id
    end

    def field_value
      @feature.title.present? ? @feature.title : ""
    end

    private

    attr_reader :feature, :project
  end
end
