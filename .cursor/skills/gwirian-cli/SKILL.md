---
name: gwirian-cli
description: Runs and composes commands for the Gwirian CLI (gwirian) to interact with the Gwirian API—list/show/create/update/delete projects, features, scenarios, and scenario executions; configure auth and base URL. Use when the user wants to manage Gwirian data via CLI, create or edit features/scenarios, execute scenarios (with Playwright or similar), or automate Gwirian operations from the terminal.
---

# Gwirian CLI skill

Use the **gwirian** CLI to talk to the Gwirian API from the terminal. This skill supports **managing** features and scenarios (create, update, delete), **listing** projects/features/scenarios for context, and **recording** scenario executions when running tests with another tool (e.g. Playwright).

**Rule: when executing scenarios, you must always use the project context.** Before running any scenario (e.g. with Playwright), fetch the project with `gwirian projects show <project-id> --json`, read the **`context`** attribute (environments, URLs, accounts, logins), and use that information to run the tests. Do not execute scenarios without having fetched and applied the project context.

## When to use

- User wants to **list or show** projects, features, scenarios, or scenario executions from the terminal
- User wants to **create, update, or delete** a feature, scenario, or scenario execution via CLI
- User wants to **execute one or more scenarios** (with Playwright or similar): use the CLI to fetch project/feature/scenario data and to **read project context**; use the other tool to run the tests and the CLI to **record scenario executions**
- User wants to set or check the API token or base URL for the CLI
- User says “with the gwirian CLI”, “via gwirian”, “gwirian command”, or similar
- You need to script or automate Gwirian API calls and the CLI is available

## How to run the CLI

- **If `gwirian` is on PATH** (after `npm link` or `npm install -g .` from gwirian-cli): run `gwirian <command> ...`.
- **Otherwise** from the gwirian-cli project root: `node dist/cli.js <command> ...` (after `npm run build`) or `npm run dev -- -- <args>` for development.
- **Non-interactive:** always pass a subcommand (e.g. `projects list`). Without a subcommand and without a TTY, the CLI prints help.

Use `--json` when you need structured output (e.g. to parse project context or IDs).

**Installing the skill:** After installing the CLI, run `gwirian install --skills` to copy this skill into `.cursor/skills/gwirian-cli` and/or `.claude/skills/gwirian-cli` (so Cursor or Claude Code can use it). Use `--target cursor` or `--target claude` to install for one only; use `--global` to install in your home directory. See the reference for full options.

## Task-oriented usage

### 1. Configure auth

- First time or missing token: run `gwirian auth` (prompt) or launch `gwirian` with no args in a TUI for setup.
- Commands that call the API require a configured token; otherwise the CLI reports “No token configured. Run \"gwirian auth\" to set your API token.”
- Do not prompt for the token in chat; point the user to `gwirian auth` or the TUI.

| Task | Command |
|------|---------|
| Set token | `gwirian auth` |
| Set token and test | `gwirian auth -t` or `gwirian auth --test` |
| Clear token | `gwirian logout` |
| Show config | `gwirian config get` |
| Set base URL | `gwirian config set base-url <url>` |

### 2. List or show projects, features, scenarios

Use these to resolve IDs and to **get project context** before executing scenarios.

| Task | Command |
|------|---------|
| List projects | `gwirian projects list` (use `--json` to parse) |
| Show project (includes context) | `gwirian projects show <project-id>` (use `--json` to read `context`) |
| List features | `gwirian features list <project-id>` |
| Show feature | `gwirian features show <project-id> <feature-id>` |
| List scenarios | `gwirian scenarios list <project-id> <feature-id>` |
| Show scenario | `gwirian scenarios show <project-id> <feature-id> <scenario-id>` |

### 3. Create or update features and scenarios

| Task | Command |
|------|---------|
| Create feature | `gwirian features create <project-id> [--title] [--description] [--tag-list]` |
| Update feature | `gwirian features update <project-id> <feature-id> [--title] [--description] [--tag-list]` |
| Delete feature | `gwirian features delete <project-id> <feature-id>` |
| Create scenario | `gwirian scenarios create <project-id> <feature-id> [--title] [--given] [--when] [--then] [--position]` |
| Update scenario | `gwirian scenarios update <project-id> <feature-id> <scenario-id> [--title] [--given] [--when] [--then] [--position]` |
| Delete scenario | `gwirian scenarios delete <project-id> <feature-id> <scenario-id>` |

### 4. Execute scenarios (with Playwright or another tool)

When the user wants to **execute one or more scenarios**:

1. **You must always fetch and use project context.**  
   Run `gwirian projects show <project-id> --json` and read the **`context`** attribute. Use it for:
   - **Environments and URLs** — base URL(s) to navigate to (e.g. local, staging, production)
   - **Accounts** — test users, logins, or magic-link emails to use
   - Any other hints (roles, feature flags, etc.)  
   Do not run scenario execution without having read and applied this context. If the project has no `context` or it is empty, ask the user for environment URL and test account details before running tests, or clearly note that context was missing.

2. **Resolve features and scenarios** with the CLI (e.g. `features list`, `scenarios list`). Use the project context to select environment and accounts for the run.

3. **Run the actual tests** with the other tool (e.g. Playwright skill or Playwright MCP): navigate to the URLs from context, use accounts from context, perform the steps implied by each scenario’s title/given/when/then.

4. **Record each execution** with the CLI:  
   `gwirian scenario-executions create <project-id> <feature-id> <scenario-id> --status passed|failed|pending [--executed-at <ISO>] [--notes "..."]`

### 5. List or record scenario executions

| Task | Command |
|------|---------|
| List executions for a scenario | `gwirian scenario-executions list <project-id> <feature-id> <scenario-id>` |
| Show one execution | `gwirian scenario-executions show <project-id> <feature-id> <scenario-id> <execution-id>` |
| Create execution (record a run) | `gwirian scenario-executions create <project-id> <feature-id> <scenario-id> [--status] [--notes] [--executed-at]` |
| Update execution | `gwirian scenario-executions update <project-id> <feature-id> <scenario-id> <execution-id> [--status] [--notes] [--executed-at]` |
| Delete execution | `gwirian scenario-executions delete <project-id> <feature-id> <scenario-id> <execution-id>` |

Status values: `passed`, `failed`, `pending`. Use `--executed-at` in ISO 8601 format when creating or updating.

## Reference

- **Full command list and examples:** [reference.md](reference.md) in this skill folder.
- **Implementation and file layout:** gwirian-cli project **AGENTS.md**.

## Tips

- Prefer running the CLI in the terminal and parsing output; use `--json` when you need structured data (especially project `context`).

