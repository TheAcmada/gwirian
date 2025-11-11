class TagListComponent < ApplicationComponent
  def initialize(taggable: nil, tags: nil, css_class: "mt-3")
    @taggable = taggable
    @tags = tags || (taggable&.tags)
    @css_class = css_class
  end

  private

  attr_reader :taggable, :tags, :css_class
end

