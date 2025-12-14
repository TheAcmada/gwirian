module Shared
  class EditableComponent < ApplicationComponent
    # Base class for editable components that use Alpine.js and htmx
    # Provides common methods for form handling and path generation

    protected

    def form_id
      "#{resource_type}-#{field_name}-form-#{resource_id}"
    end

    def wrapper_id
      "#{resource_type}-#{field_name}-wrapper-#{resource_id}"
    end

    def update_path
      raise NotImplementedError, "Subclasses must implement update_path"
    end

    def field_name
      raise NotImplementedError, "Subclasses must implement field_name"
    end

    def resource_type
      raise NotImplementedError, "Subclasses must implement resource_type"
    end

    def resource_id
      raise NotImplementedError, "Subclasses must implement resource_id"
    end

    def field_value
      raise NotImplementedError, "Subclasses must implement field_value"
    end

    def field_param_name
      "#{resource_type}[#{field_name}]"
    end

    def alpine_data
      {
        field_name => field_value.to_json
      }
    end

    def alpine_update_method
      "update#{field_name.camelize}"
    end
  end
end
