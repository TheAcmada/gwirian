# frozen_string_literal: true

module Mcp
  class Server
    SERVER_NAME = "Gwirian MCP Server"
    SERVER_VERSION = "1.0.0"

    def self.instance
      @instance ||= ::MCP::Server.new(
        name: SERVER_NAME,
        version: SERVER_VERSION,
        tools: [
          Mcp::Tools::ListProjects,
          Mcp::Tools::GetProject,
          Mcp::Tools::ListFeatures,
          Mcp::Tools::GetFeature,
          Mcp::Tools::CreateFeature,
          Mcp::Tools::UpdateFeature,
          Mcp::Tools::DeleteFeature,
          Mcp::Tools::ListScenarios,
          Mcp::Tools::GetScenario,
          Mcp::Tools::CreateScenario,
          Mcp::Tools::UpdateScenario,
          Mcp::Tools::DeleteScenario,
          Mcp::Tools::ListScenarioExecutions,
          Mcp::Tools::GetScenarioExecution,
          Mcp::Tools::CreateScenarioExecution,
          Mcp::Tools::UpdateScenarioExecution,
          Mcp::Tools::DeleteScenarioExecution
        ]
      )
    end
  end
end
