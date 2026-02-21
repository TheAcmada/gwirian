# Gwirian feature tests – reference

Do not hardcode project, feature, or scenario ids. Resolve projects via **gwirian-cli** (`gwirian --json projects list` or `gwirian projects list`); resolve features and scenarios via `gwirian features list <project-id>` and `gwirian scenarios list <project-id> <feature-id>`; determine execution order from scenario semantics (see SKILL.md). Record each run with `gwirian scenario-executions create <project-id> <feature-id> <scenario-id> --status passed|failed|pending [--notes "..."]`.

## Resolving projects

- **Spec project** (where features and scenarios are defined): get id from `gwirian projects list` (or `gwirian --json projects list`), then match by name (e.g. "Gwirian") or use the id the user provides. The Gwirian project is not necessarily id 1.
- **Test project** (where Playwright runs): same—use the CLI list and match by name (e.g. "Test") or use the id the user provides.
- If multiple projects could match or the user did not specify, ask which project to use for spec and which for test.

## gwirian-cli commands (use these, not MCP)

- List projects: `gwirian projects list` or `gwirian --json projects list`
- List features: `gwirian features list <project-id>`
- List scenarios: `gwirian scenarios list <project-id> <feature-id>`
- Project context (optional): `gwirian projects show <project-id> --json` — read the `context` attribute for accounts, environments, URLs
- Record execution: `gwirian scenario-executions create <project-id> <feature-id> <scenario-id> --status passed|failed|pending [--executed-at <ISO 8601>] [--notes "..."]`

The CLI must be configured with `gwirian auth` before use. Default base URL is https://app.gwirian.com; use `gwirian config set base-url <url>` for self-hosted.

## Other defaults

- **App base URL:** ask user — **local** `http://localhost:3000` or **production** `https://app.gwirian.com`

## Logical order rules (summary)

Order is derived from scenario titles/descriptions:

1. Create/add before delete/remove for the same entity.
2. Feature create/edit before scenario add/edit; scenario add/edit before execution; execution before scenario delete; scenario delete before feature delete.
3. Project/settings (including team, delete project) last; "Deleting the project" very last and optional.

Use scenario `position` only when dependencies do not impose a different order.
