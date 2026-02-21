---
name: gwirian-feature-tests
description: Runs E2E tests for one or more Gwirian features using the Playwright skill (playwright-cli) or, if unavailable, Playwright MCP on a chosen target (local or production), and records results via the gwirian-cli skill. Use when the user wants to test features, run scenario tests, execute BDD scenarios, or "lancer les tests" for specific features.
---

# Run Gwirian feature tests

Run E2E tests for one or more features from a **spec project** (where features/scenarios are defined) against a **test project** (where the app is exercised), using the **Playwright skill** (playwright-cli) for browser automation when available—otherwise use **Playwright MCP**—then record scenario executions in Gwirian via **gwirian-cli**. Project ids are not fixed; resolve them via the CLI and user input.

## Target environment (required)

**Before starting**, ask the user which environment to run against:

- **Local:** `http://localhost:3000` (app must be running locally)
- **Production:** `https://app.gwirian.com`

Use the chosen base URL for all navigation (e.g. `<base>/session/new`, `<base>/frocher/projects/2`, …). If the user does not specify, ask.

## When to use

- User asks to run tests for one or more features (by name or id)
- User says "lancer les tests" (d'une ou plusieurs features)
- User wants to execute the BDD scenarios against the app (local or production)

## Prerequisites

- **gwirian-cli** skill: use the **gwirian** CLI in the terminal. Run `gwirian --json projects list` to list projects, `gwirian features list <project-id>` to list features, `gwirian scenarios list <project-id> <feature-id>` to list scenarios, and `gwirian scenario-executions create <project-id> <feature-id> <scenario-id> --status passed|failed|pending [--notes "..."]` to record each run. Optionally run `gwirian projects show <project-id> --json` to read project **context** (accounts, environments). The CLI must be configured with `gwirian auth` beforehand.
- **Browser automation:** Prefer the **Playwright skill** (playwright-cli): run `playwright-cli` commands (open, goto, snapshot, click, fill, type, etc.) and use refs from snapshot output. If the Playwright skill is not available (e.g. playwright-cli not in path or skill not loaded), use **Playwright MCP** instead (browser_navigate, browser_snapshot, browser_click, browser_fill_form, etc.).
- **Spec project** and **test project** resolved via `gwirian --json projects list` (match by name or ask user); **test account** (e.g. frocher@gwirian.com); user may provide email and will provide magic link code when prompted

## Workflow

### 1. Resolve spec project, test project, and features to run

- Run `gwirian --json projects list` (or `gwirian projects list` and parse) to get all projects. Do not assume any project id (e.g. Gwirian is not necessarily id 1).
- **Spec project** (source of feature/scenario definitions): use the project id the user gives, or match by project name (e.g. "Gwirian") from the list. If ambiguous, ask.
- **Test project** (where Playwright runs): use the project id the user gives, or match by name (e.g. "Test") from the list. If ambiguous, ask.
- Run `gwirian features list <spec_project_id>` to get features (parse output for id and title).
- If user names specific features: match by id or by title to the returned list.
- If user says "all features": take every feature from that project.
- Do not assume any fixed project or feature ids; use only CLI output and user input.

### 2. Get scenarios and determine logical execution order

For each feature to test, run `gwirian scenarios list <project_id> <feature_id>` and parse the output to get scenario id, title, position, feature_id.

**Determine order from scenario semantics (titles/descriptions), not from feature ids:**

- **Create before delete:** Scenarios that create or add something (e.g. "Creating a feature", "Adding a scenario") must run before scenarios that delete or remove the same entity ("Deleting a feature", "Deleting a scenario").
- **Feature before scenario:** Creating/editing a feature must run before adding or editing scenarios (scenarios live under a feature).
- **Scenarios before execution:** Adding/editing scenarios must run before "execution" or "run" or "record pass/fail" scenarios (execution acts on existing scenarios).
- **Delete scenario before delete feature:** If both exist, deleting a scenario runs before deleting the feature (clean up children before parent).
- **Project/settings last:** Scenarios about project settings, team members, or "Deleting the project" run last; put "Deleting the project" (or equivalent) very last and skip unless the user explicitly accepts destroying the test project.
- **Within a feature:** Use scenario `position` when no dependency implies otherwise; otherwise apply the rules above to build a single ordered list of all scenarios to run.

Produce one ordered list of `(project_id, feature_id, scenario_id, title)` and execute in that order. Do not hardcode feature or scenario ids; derive order only from the CLI data and the dependency rules above.

### 3. Login and open Test project

**If Playwright skill is available:** Use `playwright-cli open`, `playwright-cli goto <base_url>/session/new`, `playwright-cli snapshot` for refs, then `playwright-cli fill` / `playwright-cli click` as needed.

**If Playwright skill is not available:** Use Playwright MCP: `browser_navigate` to `<base_url>/session/new`, `browser_snapshot` to get refs, then `browser_fill_form` and `browser_click` with those refs.

Common steps (same intent with either tool):
- Navigate to `<base_url>/session/new` (base_url = environment chosen in "Target environment").
- Fill email (user-provided or default e.g. frocher@gwirian.com), click "Get code".
- **Ask user for the verification code** sent by email, then fill code and click "Verify".
- Go to Projects, open the **test project** resolved in step 1 (click the project link; all URLs use `<base_url>`). Snapshot after each navigation to get current refs.

### 4. Execute scenarios

**If Playwright skill is available:** Use `playwright-cli snapshot` to get refs, then `playwright-cli click`, `playwright-cli fill`, `playwright-cli type`, etc. with those refs.

**If Playwright skill is not available:** Use Playwright MCP: `browser_snapshot` then `browser_click`, `browser_fill_form`, `browser_type` with the refs from the snapshot.

For each scenario in the computed order, infer the UI actions from the **scenario title and description** (and feature context):

- **Creating a feature / New feature:** Features list → click "New feature" button ref → expect redirect to feature show page; snapshot to confirm.
- **Editing feature (title, description, tag, rename, add/remove tag):** On feature show page: title = contenteditable h1 (click ref, type new text, blur via click elsewhere); description = contenteditable paragraph; tags = "Add tag" button, fill tag input, submit; "Remove tag X".
- **Adding a scenario / New scenario:** Click "Add scenario" link ref → new scenario appears; snapshot for new refs.
- **Editing scenario (title, Given, When, Then):** Contenteditable refs on the scenario block; fill then click elsewhere to blur.
- **Execution / Run / Record pass or fail:** Click "Run" → snapshot → select scenario checkbox refs, click "Continue" → click Pass (or Fail) ref → "Submit".
- **Deleting a scenario:** Click Open menu ref on that scenario → Delete menuitem → Confirm button.
- **Deleting a feature:** Features list → Open menu on feature card → Delete → Confirm.
- **Project settings (update name/description, team member add/change/remove):** Go to Settings link, fill form refs, Save; member section if applicable; skip "Delete project" unless user accepted.

Snapshot after important steps to confirm success and get refs for the next action.

### 5. Record results in Gwirian

For each executed scenario run in the terminal:

```bash
gwirian scenario-executions create <project_id> <feature_id> <scenario_id> --status passed|failed|pending [--notes "Playwright E2E - <short description>"]
```

Use `passed` when the UI behaved as expected, `failed` when a step failed or was skipped (e.g. "user not in workspace"), `pending` when intentionally skipped (e.g. delete project). Optionally pass `--executed-at` in ISO 8601 format.

### 6. Report summary

Return a short table: Feature name, scenario titles, Passed/Failed/Skipped, and note any environment skips (single user workspace, project delete skipped).

## Reference

- Project resolution and defaults: [reference.md](reference.md). Do not hardcode project, feature, or scenario ids; resolve via gwirian-cli and user input.
- **Gwirian data:** Use the **gwirian-cli** skill—run `gwirian` in the terminal (`gwirian --json projects list`, `gwirian features list <project-id>`, `gwirian scenarios list <project-id> <feature-id>`, `gwirian scenario-executions create ... --status passed|failed|pending`). Do not use the Gwirian MCP server.
- Browser automation: prefer the **Playwright skill** (playwright-cli): run `playwright-cli` in the terminal (open, goto, snapshot, click, fill, type, etc.). If the Playwright skill is not available, use **Playwright MCP** (browser_navigate, browser_snapshot, browser_click, browser_fill_form, browser_type, etc.).

## Tips

- **Single workspace member:** Scenarios "Adding a team member", "Changing role", "Removing member" need 2+ members; mark as failed with note "Skipped: single user workspace" if not runnable.
- **Delete project:** Only run "Deleting the project" if the user explicitly accepts that the Test project will be destroyed.
- If a browser is already open on the app (same base URL) and logged in (playwright-cli or MCP), skip login and go straight to the Test project and scenario steps (use snapshot to get refs).
- **Local:** Ensure the Rails app is running on port 3000 before starting (e.g. `bin/rails s`).
