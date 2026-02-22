# Gwirian CLI — API reference

Commands and options only. For task-oriented usage, examples, and recommendations, see [SKILL.md](SKILL.md).

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
| `gwirian projects show <project-id>` | Show one project; response includes `context` when present |

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

**Create/update options:** `--status <status>` (`passed` | `failed` | `pending`), `--notes <notes>` (optional), `--executed-at <iso>` (optional; ISO 8601, defaults to current time on create), `--tag-list <list>` (optional; comma-separated). List and show return `tag_list` on each execution.
