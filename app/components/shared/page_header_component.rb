# frozen_string_literal: true

module Shared
  class PageHeaderComponent < ApplicationComponent
    renders_one :actions

    def initialize(title:, subtitle: nil, back_path: nil)
      @title = title
      @subtitle = subtitle
      @back_path = back_path
    end

    private

    attr_reader :title, :subtitle, :back_path

    def back_path?
      back_path.present?
    end

    def subtitle?
      subtitle.present?
    end
  end
end
