# MCP Client Configuration Guide

This guide explains how to configure an MCP client to connect to the Gwirian MCP Server.

## Prerequisites

1. **Get Your API Token**
   - Log in to your Gwirian account
   - Navigate to your workspace settings (or workspace members page)
   - Generate an API token for the workspace (if you don't have one)
   - Copy the API token - you'll need it for client configuration
   - **Important**: API tokens are workspace-scoped. Each workspace has its own API token, and the token determines which workspace context the MCP tools will operate in. You can have different tokens for different workspaces.

2. **Server URL**
   - Development: `http://localhost:3000/mcp`
   - Production: `https://your-domain.com/mcp`

## Example configuration for Cursor

*Note: This is an example configuration for Cursor. For specific configuration details, please refer to your tool's documentation.*

To configure the Gwirian MCP server in Cursor, add it to your Cursor MCP settings:

1. Open Cursor Settings
2. Navigate to **Features** → **Model Context Protocol**
3. Click **Add Server** or edit your MCP settings file

**Configuration file location**: `~/.cursor/mcp.json` (or in Cursor settings)

```json
{
  "mcpServers": {
    "gwirian": {
      "url": "http://localhost:3000/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_API_TOKEN_HERE"
      }
    }
  }
}
```

**For production**, replace the URL with your production server:
```json
{
  "mcpServers": {
    "gwirian": {
      "url": "https://your-domain.com/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_API_TOKEN_HERE"
      }
    }
  }
}
```

**Note**: Make sure to replace `YOUR_API_TOKEN_HERE` with your actual API token from your workspace settings. Remember that API tokens are workspace-scoped, so the token you use will determine which workspace the MCP tools access.

## Authentication

The MCP server uses workspace-scoped API token authentication. The API token is associated with a specific workspace membership, and all MCP tool operations will be performed within that workspace's context.

Include the token in the `Authorization` header:

```
Authorization: Bearer YOUR_API_TOKEN_HERE
```

Alternatively, you can pass it as a query parameter (though header is preferred):

```
?api_token=YOUR_API_TOKEN_HERE
```

**Workspace Context**: When you authenticate with an API token, the MCP server automatically sets the workspace context based on the workspace associated with that token. All project operations will be scoped to that workspace. If you need to access multiple workspaces, you'll need to use different API tokens for each workspace.

## Available Tools

Once connected, you can use the following tools. All operations are scoped to the workspace associated with your API token:

### Projects (Read-only)
- `list_projects` - List all accessible projects in the workspace
- `get_project` - Get project details with executions and team members

Project payloads include an optional `context` field (text) for test context: environments and URLs, test accounts and logins, and other hints for scenario execution.

### Features (Full CRUD)
- `list_features` - List features for a project
- `get_feature` - Get feature details with executions
- `create_feature` - Create a new feature
- `update_feature` - Update an existing feature
- `delete_feature` - Delete a feature

### Scenarios (Full CRUD)
- `list_scenarios` - List scenarios for a feature
- `get_scenario` - Get scenario details with executions
- `create_scenario` - Create a new scenario
- `update_scenario` - Update a scenario
- `delete_scenario` - Delete a scenario

### Scenario Executions (Full CRUD)
- `list_scenario_executions` - List executions for a scenario
- `get_scenario_execution` - Get execution details
- `create_scenario_execution` - Create a new execution
- `update_scenario_execution` - Update an execution
- `delete_scenario_execution` - Delete an execution

Executions support an optional `tag_list` (comma-separated string) for test type (e.g. e2e, smoke), version, bugfix info, or other metadata. Create and update tools accept `tag_list`; list and get include `tag_list` in each execution.

## Testing the Connection

You can test the connection using curl. Replace `YOUR_API_TOKEN` with your actual API token:

```bash
# Health check (requires Bearer token authentication)
curl http://localhost:3000/mcp/health \
  -H "Authorization: Bearer YOUR_API_TOKEN"

# Initialize (requires Bearer token authentication)
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {}
  }'

# List tools (requires Bearer token authentication)
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/list",
    "params": {}
  }'

# Call a tool (requires Bearer token authentication)
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "jsonrpc": "2.0",
    "id": 3,
    "method": "tools/call",
    "params": {
      "name": "list_projects",
      "arguments": {}
    }
  }'
```

**Note**: You can also use an environment variable for the token:
```bash
export API_TOKEN="your_actual_token_here"
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_TOKEN" \
  -d '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}}'
```

## Troubleshooting

### Authentication Errors
- Ensure your API token is valid and not expired
- Check that the token is included in the `Authorization` header with the `Bearer ` prefix
- Verify the token hasn't been revoked
- Confirm that the API token belongs to a valid workspace membership
- If you're a member of multiple workspaces, make sure you're using the correct token for the workspace you want to access

### Connection Errors
- Verify the server URL is correct
- Check that the Rails server is running
- Ensure CORS is properly configured if accessing from a browser

### Tool Not Found Errors
- Use `tools/list` to see all available tools
- Verify the tool name is spelled correctly
- Check that you have the necessary permissions for the operation

