module Shared
  class DropdownMenuComponent < ApplicationComponent
    # Base class for dropdown menu components
    # Provides common structure for feature and scenario dropdown menus

    protected

    def delete_path
      raise NotImplementedError, "Subclasses must implement delete_path"
    end

    def delete_target
      raise NotImplementedError, "Subclasses must implement delete_target"
    end

    def confirmation_message
      raise NotImplementedError, "Subclasses must implement confirmation_message"
    end

    def button_classes
      "flex items-center justify-center w-8 h-8 rounded-full cursor-pointer hover:bg-zinc-100 dark:hover:bg-gray-700 focus:outline-none focus-visible:outline-none focus-visible:ring-3 focus-visible:ring-accent-500"
    end
  end
end
