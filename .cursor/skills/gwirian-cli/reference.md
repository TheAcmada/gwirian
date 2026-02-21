# Gwirian CLI — Command reference

This file lists all **gwirian** commands for use by agents. Run from the gwirian-cli project root as `node dist/cli.js <command> ...` (after `npm run build`) or as `gwirian <command> ...` if the CLI is on PATH.

## Global options

| Option | Description |
|--------|-------------|
| `--base-url <url>` | Override API base URL for this run (does not change saved config) |
| `--json` | Output raw JSON (for list/show); use when parsing programmatically |

---

## Install (skills)

| Command | Description |
|---------|-------------|
| `gwirian install --skills` | Install the gwirian-cli skill for Cursor and Claude (into `.cursor/skills/gwirian-cli` and `.claude/skills/gwirian-cli` in the current directory) |
| `gwirian install --skills --target cursor` | Install only into `.cursor/skills/gwirian-cli` |
| `gwirian install --skills --target claude` | Install only into `.claude/skills/gwirian-cli` |
| `gwirian install --skills --target both` | Same as default (both targets) |
| `gwirian install --skills --global` | Install into user home: `~/.cursor/skills/gwirian-cli` and/or `~/.claude/skills/gwirian-cli` |

**Options:** `--target <cursor|claude|both>` (default: `both`), `-g` / `--global` (install in home instead of current directory).

---

## Auth and config

| Command | Description |
|---------|-------------|
| `gwirian auth` | Prompt for API token and save it |
| `gwirian auth -t` / `gwirian auth --test` | Same + test token with GET projects |
| `gwirian logout` | Clear stored token |
| `gwirian config get` | Print base URL and whether a token is set |
| `gwirian config set base-url <url>` | Set API base URL (default https://app.gwirian.com) |

Config file: `~/.config/gwirian-cli/config.json` (or `$XDG_CONFIG_HOME/gwirian-cli/config.json`). Do not log or echo the token.

---

## Projects

| Command | Description |
|---------|-------------|
| `gwirian projects list` | List all projects |
| `gwirian projects show <project-id>` | Show one project (includes `context` when present) |

**Project context (required for scenario execution):** The API returns a `context` attribute on the project (environments/URLs, accounts, logins, etc.). **When executing scenarios, you must always** fetch the project with `gwirian projects show <project-id> --json`, read `context`, and use it to run the tests (URLs, accounts). Do not run scenario execution without using the project context.

---

## Features

| Command | Description |
|---------|-------------|
| `gwirian features list <project-id>` | List features |
| `gwirian features show <project-id> <feature-id>` | Show one feature |
| `gwirian features create <project-id> [options]` | Create feature |
| `gwirian features update <project-id> <feature-id> [options]` | Update feature |
| `gwirian features delete <project-id> <feature-id>` | Delete feature |

**Create/update options:** `--title <title>`, `--description <desc>`, `--tag-list <tags>` (comma-separated).

---

## Scenarios

| Command | Description |
|---------|-------------|
| `gwirian scenarios list <project-id> <feature-id>` | List scenarios |
| `gwirian scenarios show <project-id> <feature-id> <scenario-id>` | Show one scenario |
| `gwirian scenarios create <project-id> <feature-id> [options]` | Create scenario |
| `gwirian scenarios update <project-id> <feature-id> <scenario-id> [options]` | Update scenario |
| `gwirian scenarios delete <project-id> <feature-id> <scenario-id>` | Delete scenario |

**Create/update options:** `--title <title>`, `--given <given>`, `--when <when>`, `--then <then>`, `--position <n>`.

---

## Scenario executions

| Command | Description |
|---------|-------------|
| `gwirian scenario-executions list <project-id> <feature-id> <scenario-id>` | List executions for a scenario |
| `gwirian scenario-executions show <project-id> <feature-id> <scenario-id> <execution-id>` | Show one execution |
| `gwirian scenario-executions create <project-id> <feature-id> <scenario-id> [options]` | Create execution (record a run) |
| `gwirian scenario-executions update <project-id> <feature-id> <scenario-id> <execution-id> [options]` | Update execution |
| `gwirian scenario-executions delete <project-id> <feature-id> <scenario-id> <execution-id>` | Delete execution |

**Create/update options:** `--status <status>` (`passed` | `failed` | `pending`), `--notes <notes>`, `--executed-at <iso>` (ISO 8601), `--tag-list <list>` (comma-separated tags: test type, version, bugfix, etc.). List and show return `tag_list` on each execution.

---

## Examples

```bash
# List projects as JSON (for parsing)
gwirian --json projects list

# Get project details including context (required before executing scenarios)
gwirian --json projects show 1

# Create a feature
gwirian features create 1 --title "Login" --description "User can sign in"

# Create a scenario
gwirian scenarios create 1 2 --title "Successful login" --given "user has an account" --when "user submits valid credentials" --then "user is redirected to dashboard"

# Record a scenario execution (e.g. after Playwright run)
gwirian scenario-executions create 1 2 3 --status passed --executed-at "2025-02-21T10:00:00Z" --notes "Playwright E2E"

# Override base URL for one run
gwirian --base-url https://staging.example.com features list 1
```
