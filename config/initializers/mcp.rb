Rails.application.config.to_prepare do
  # Register global MCP configuration
  MCP.configure do |config|
    config.exception_reporter = ->(exception, server_context) {
      Rails.logger.error "MCP Error: #{exception.message}"
    }

    config.instrumentation_callback = ->(data) {
      Rails.logger.info "MCP: #{data[:method]} - #{data[:duration]}s"
    }
  end

   # Create our server instance and register tools
   Mcp::Server.instance
end
