# Gwirian feature tests – reference

Do not hardcode project, feature, or scenario ids. Resolve projects via `list_projects`; resolve features/scenarios via `list_features` / `list_scenarios`; determine execution order from scenario semantics (see SKILL.md).

## Resolving projects

- **Spec project** (where features and scenarios are defined): get id from `mcp_gwirian_list_projects()`, then match by name (e.g. “Gwirian”) or use the id the user provides. The Gwirian project is not necessarily id 1.
- **Test project** (where Playwright runs): same—use `list_projects` and match by name (e.g. “Test”) or use the id the user provides.
- If multiple projects could match or the user did not specify, ask which project to use for spec and which for test.

## Other defaults

- **App base URL:** ask user — **local** `http://localhost:3000` or **production** `https://app.gwirian.com`

## Logical order rules (summary)

Order is derived from scenario titles/descriptions:

1. Create/add before delete/remove for the same entity.
2. Feature create/edit before scenario add/edit; scenario add/edit before execution; execution before scenario delete; scenario delete before feature delete.
3. Project/settings (including team, delete project) last; “Deleting the project” very last and optional.

Use scenario `position` only when dependencies do not impose a different order.
