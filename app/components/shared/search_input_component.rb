# frozen_string_literal: true

module Shared
  class SearchInputComponent < ApplicationComponent
    def initialize(url:, target_id:, placeholder:, param_name: "q", value: nil)
      @url = url
      @target_id = target_id
      @placeholder = placeholder
      @param_name = param_name
      @value = value.to_s
    end

    private

    attr_reader :url, :target_id, :placeholder, :param_name, :value
  end
end
