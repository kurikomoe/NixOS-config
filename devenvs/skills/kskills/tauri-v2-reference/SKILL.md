---
name: tauri-v2-reference
description: Consult the latest official Tauri v2 documentation before answering Tauri questions, then produce practical, up-to-date solutions with links. Use this whenever the user mentions Tauri, tauri.conf, src-tauri, invoke, commands, WebviewWindow, capabilities, permissions, plugins, updater, tray, shell, mobile, or migrating from Tauri v1—even if they do not explicitly ask to "look up docs." Prioritize v2 docs and catch v1-era APIs, package names, config keys, and allowlist patterns before giving code.
---

# Tauri v2 Reference

Use this skill to keep Tauri help aligned with the latest official Tauri v2 docs instead of memory alone.

## Why this skill exists

Tauri answers go stale easily because v2 changed module names, plugin layout, security configuration, and parts of the JS/Rust API surface. Users usually want working code, not a mixed v1/v2 answer that compiles nowhere.

Your job is to:

1. Verify against official Tauri v2 docs first.
2. Detect whether the user needs core API, a plugin, config, security/capabilities, or migration guidance.
3. Give a practical answer with minimal but sufficient explanation.
4. Include doc links for the exact APIs or guides you relied on.

## Default behavior

When this skill triggers:

1. Identify the topic from the user request.
2. Read the most relevant official Tauri v2 page(s) before answering.
3. Prefer current v2 guides/reference pages over recollection.
4. If the request smells like old Tauri v1 usage, call that out explicitly and provide the v2 replacement.
5. Return a concrete answer: code, config, commands, migration diff, or debugging steps.
6. End with a short `References` list containing the exact Tauri URLs used.

## Documentation lookup order

Choose the smallest set of pages that fully answers the question.

### 1. General entry points

- Quick start / guides: `https://v2.tauri.app/start/`
- Security capabilities guide: `https://v2.tauri.app/security/capabilities/`
- Capability reference: `https://v2.tauri.app/reference/acl/capability/`
- Config reference: `https://v2.tauri.app/reference/config/`
- Migration from v1: `https://v2.tauri.app/start/migrate/from-tauri-1/`

### 2. Development topics

- Calling Rust from frontend / commands / invoke: `https://v2.tauri.app/develop/calling-rust/`
- Calling frontend from Rust / events / channels: `https://v2.tauri.app/develop/calling-frontend/`
- Configuration files: `https://v2.tauri.app/develop/configuration-files/`
- Sidecars / external binaries: `https://v2.tauri.app/develop/sidecar/`
- Resources: `https://v2.tauri.app/develop/resources/`

### 3. Plugin pages

If the feature is not clearly in `@tauri-apps/api/core`, `event`, `path`, or `webviewWindow`, check plugin docs first.

Examples:

- Shell: `https://v2.tauri.app/plugin/shell/`
- Dialog: `https://v2.tauri.app/plugin/dialog/`
- FS: `https://v2.tauri.app/plugin/file-system/`
- Process: `https://v2.tauri.app/plugin/process/`
- Updater: `https://v2.tauri.app/plugin/updater/`
- Global shortcut: `https://v2.tauri.app/plugin/global-shortcut/`
- HTTP client: `https://v2.tauri.app/plugin/http-client/`
- Store: `https://v2.tauri.app/plugin/store/`

### 4. Version-specific release pages

If the user asks whether an API exists in a specific version, or if a feature seems recently added, consult the release pages under:

- `https://v2.tauri.app/release/`

Use the latest available v2 release page that matches the package involved.

## Tauri v2 rules you should actively enforce

### Prefer v2 names and packages

- Frontend invoke comes from `@tauri-apps/api/core`, not `@tauri-apps/api/tauri`.
- Window APIs are under `@tauri-apps/api/webviewWindow`, not the old `window` import path when the user means `WebviewWindow`.
- Many non-core JS APIs moved from `@tauri-apps/api/*` to `@tauri-apps/plugin-*` packages.
- Rust-side features like updater, shell, dialog, fs, http, clipboard, process, notifications, CLI, OS, and global shortcuts often live in plugins now.

### Security model changed in v2

- `allowlist` is gone; do not recommend v1 allowlist configuration.
- Use capabilities / permissions instead.
- Capability files usually live in `src-tauri/capabilities/`.
- Capabilities grant permissions to specific windows/webviews and may be platform-specific.
- For dangerous APIs like shell execution, explain the required capability permission entries.

### Migration pitfalls to watch for

If the user shows old snippets, translate them instead of patching around them.

Common v1 -> v2 fixes:

- `@tauri-apps/api/tauri` -> `@tauri-apps/api/core`
- `@tauri-apps/api/window` -> `@tauri-apps/api/webviewWindow` when using `WebviewWindow`
- `@tauri-apps/api/fs`, `dialog`, `shell`, `http`, `process`, etc. -> corresponding `@tauri-apps/plugin-*`
- `tauri.conf.json > tauri` -> many values moved under `app`, `plugins`, or top-level config
- `allowlist` -> capabilities / permissions
- updater is a plugin, not the old built-in pattern
- system tray APIs were renamed around `tray` / `trayIcon`
- `Window` / `WindowBuilder` on Rust side may need `WebviewWindow` / `WebviewWindowBuilder`

## Response format

Default output should look like this unless the user asks otherwise:

### 1. Short answer

One short paragraph saying what the right v2 approach is.

### 2. Implementation

Provide the exact code/config/commands. Keep it copy-pasteable.

### 3. Notes

Only include the non-obvious caveats that matter, such as:

- required plugin install/setup
- capability permissions needed
- migration caveats
- platform limitations

### 4. References

List the official Tauri v2 URLs you used.

## Heuristics by request type

### If the user asks for code using a Tauri API

1. Determine whether it is core, plugin, or custom command work.
2. Verify import path and setup steps from docs.
3. Include both frontend and Rust/plugin setup when needed.
4. If permissions are required, include the capability snippet.

### If the user asks about `invoke`, commands, or Rust/frontend communication

Use the calling-Rust docs. Prefer:

- `#[tauri::command]`
- `tauri::generate_handler!`
- `invoke` from `@tauri-apps/api/core`
- async command guidance when work may block

Call out command argument casing and error serialization when relevant.

### If the user asks about shell/process/opening apps or URLs

Check whether they need:

- `plugin-shell` for child processes
- `plugin-opener` for opening URLs if the docs indicate opener is now the better fit

Do not forget permissions/capabilities. For shell execution, include the required `shell:allow-*` capability example or explain the exact permission to add.

### If the user asks about capabilities / permission errors

Use the security capabilities guide and capability reference.

Explain:

- which capability file to add or modify
- which window labels it applies to
- which permission identifiers are needed
- that multiple capabilities can merge boundaries for the same window/webview

### If the user asks to migrate old code

Be explicit:

- say which parts are v1-only
- show the v2 replacement side by side if useful
- update package names, imports, config keys, and capability setup

## Quality bar

Before answering, check yourself:

- Did I verify this against official Tauri v2 docs?
- Am I accidentally using a v1 package name or config key?
- If this uses a plugin, did I include installation and initialization?
- If this uses privileged functionality, did I mention capabilities/permissions?
- Are my links official `v2.tauri.app` links?

## Example patterns

### Example 1

Input: “Tauri 2 怎么在前端调用 Rust 命令并返回 JSON？”

Good answer shape:

- explain that v2 still uses commands + `invoke` from `@tauri-apps/api/core`
- show `#[tauri::command]` Rust code
- show `invoke` frontend code
- mention `serde::Serialize` / `Deserialize` requirements if needed
- link `develop/calling-rust`

### Example 2

Input: “我想在 Tauri 里执行 shell 命令，为什么报 permission denied？”

Good answer shape:

- explain that v2 uses `@tauri-apps/plugin-shell`
- show install/init steps
- add capability permission snippet such as `shell:allow-execute`
- mention command scoping for safety
- link plugin shell docs + capabilities docs

### Example 3

Input: “把这段 Tauri 1 的 allowlist/fs/window 代码改成 v2”

Good answer shape:

- identify each outdated import/config
- replace with plugin/core/webviewWindow equivalents
- replace allowlist with capability config
- keep final answer as a migration patch, not just prose
