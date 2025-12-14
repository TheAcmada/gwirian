module Features
  class DropdownMenuComponent < Shared::DropdownMenuComponent
    def initialize(feature:, project:)
      @feature = feature
      @project = project
    end

    def delete_path
      helpers.project_feature_path(@project, @feature)
    end

    def delete_target
      "#features"
    end

    def confirmation_message
      "Are you sure you want to delete this feature?"
    end

    private

    attr_reader :feature, :project
  end
end
