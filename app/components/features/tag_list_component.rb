module Features
  class TagListComponent < Tags::ListComponent
    def initialize(feature:, project:, css_class: "mt-4")
      super(taggable: feature, project: project, css_class: css_class)
    end
  end
end
