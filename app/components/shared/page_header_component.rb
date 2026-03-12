# frozen_string_literal: true

module Shared
  class PageHeaderComponent < ApplicationComponent
    renders_one :actions

    def initialize(title:, subtitle: nil, back_path: nil, size: :default)
      @title = title
      @subtitle = subtitle
      @back_path = back_path
      @size = size.to_sym
    end

    private

    attr_reader :title, :subtitle, :back_path, :size

    def title_size_class
      case size
      when :large then "text-3xl sm:text-4xl font-extrabold tracking-tight"
      else "text-3xl font-bold tracking-tight"
      end
    end

    def back_path?
      back_path.present?
    end

    def subtitle?
      subtitle.present?
    end
  end
end
