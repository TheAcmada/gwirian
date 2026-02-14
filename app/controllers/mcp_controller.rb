# frozen_string_literal: true

class McpController < ActionController::Base
  include Authentication::ViaApiToken
  skip_before_action :verify_authenticity_token

  def handle
    server = Mcp::Server.instance
    body = request.body.read

    Thread.current[:mcp_server_context] = build_server_context
    request_id = nil

    begin
      request_data = JSON.parse(body) rescue {}
      request_id = request_data["id"]

      server.server_context = Thread.current[:mcp_server_context]
      result = server.handle_json(body)
      render json: result
    rescue JSON::ParserError => e
      Rails.logger.error("MCP Controller JSON Parse Error: #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}")
      render json: {
        jsonrpc: "2.0",
        id: request_id,
        error: { code: -32700, message: "Parse error: #{e.message}" }
      }, status: :bad_request
    rescue StandardError => e
      Rails.logger.error("MCP Controller Error: #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}")
      render json: {
        jsonrpc: "2.0",
        id: request_id,
        error: { code: -32000, message: "Internal error: #{e.message}" }
      }, status: :internal_server_error
    ensure
      Thread.current[:mcp_server_context] = nil
    end
  end

  private

  def render_token_unauthorized
    render json: {
      jsonrpc: "2.0",
      id: nil,
      error: { code: -32001, message: "Unauthorized" }
    }, status: :unauthorized
  end

  def build_server_context
    {
      current_user: current_user,
      current_workspace: Current.workspace,
      request_id: request.request_id,
      ip_address: request.remote_ip
    }
  end
end
