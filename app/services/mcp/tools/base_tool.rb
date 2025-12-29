# frozen_string_literal: true

module Mcp
  module Tools
    class BaseTool < MCP::Tool
      def self.authorize!(user, action, subject)
        ability = Ability.new(user)
        ability.authorize!(action, subject)
      end

      def self.can?(user, action, subject)
        ability = Ability.new(user)
        ability.can?(action, subject)
      end

      def self.success_result(content)
        text = if content.is_a?(String)
          content
        elsif content.respond_to?(:to_json)
          content.to_json
        else
          JSON.generate(content)
        end

        MCP::Tool::Response.new([ {
          type: "text",
          text: text
        } ])
      end

      def self.error_result(message, code: -32000)
        error_data = {
          error: {
            code: code,
            message: message
          }
        }

        MCP::Tool::Response.new([ {
          type: "text",
          text: error_data.to_json
        } ])
      end

      def self.safe_user_email(user)
        user&.email_address || "unknown"
      end

      def self.handle_errors(&block)
        block.call
      rescue CanCan::AccessDenied => e
        error_result("Access denied: #{e.message}", code: -32001)
      rescue ActiveRecord::RecordNotFound => e
        error_result("Record not found: #{e.message}", code: -32002)
      rescue ActiveRecord::RecordInvalid => e
        error_result("Validation failed: #{e.record.errors.full_messages.join(', ')}", code: -32003)
      rescue ArgumentError => e
        error_result("Invalid argument: #{e.message}", code: -32004)
      rescue StandardError => e
        Rails.logger.error("MCP Tool Error: #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}")
        error_result("Internal error: #{e.message}", code: -32000)
      end
    end
  end
end
