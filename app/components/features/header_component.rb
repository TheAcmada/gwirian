module Features
  class HeaderComponent < ApplicationComponent
    def initialize(feature:, project:)
      @feature = feature
      @project = project
    end

    private

    attr_reader :feature, :project

    def can_execute?
      helpers.can?(:execute, feature)
    end
  end
end
