# frozen_string_literal: true

class McpController < ActionController::Base
  before_action :authenticate_with_api_token!
  skip_before_action :verify_authenticity_token

  def handle
    server = Mcp::Server.instance
    body = request.body.read

    Thread.current[:mcp_server_context] = build_server_context
    request_id = nil

    begin
      # Parse the request JSON to get the id for error reporting before the main processing
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

  def build_server_context
    {
      current_user: current_user,
      current_workspace: Current.workspace,
      request_id: request.request_id,
      ip_address: request.remote_ip
    }
  end

  def current_user
    @current_user
  end

  def authenticate_with_api_token!
    token = request.headers["authorization"]&.split(" ")&.last || params[:api_token]
    @current_workspace_member = WorkspaceMember.find_by(api_token: token)
    unless @current_workspace_member&.api_token_valid?
      render json: {
        jsonrpc: "2.0",
        id: nil,
        error: { code: -32001, message: "Unauthorized" }
      }, status: :unauthorized
      return
    end
    @current_user = @current_workspace_member.user
    Current.workspace = @current_workspace_member.workspace
  end
end
