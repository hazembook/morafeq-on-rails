# Project Instructions for AI Agents

This file provides instructions and context for AI coding agents working on this project.

<!-- BEGIN BEADS INTEGRATION v:1 profile:full hash:0a1bbe8a -->
## Issue Tracking with bd (beads)

**IMPORTANT**: This project uses **bd (beads)** for ALL issue tracking. Do NOT use markdown TODOs, task lists, or other tracking methods.

### Why bd?

- Dependency-aware: Track blockers and relationships between issues
- Git-friendly: Dolt-powered version control with native sync
- Agent-optimized: JSON output, ready work detection, discovered-from links
- Prevents duplicate tracking systems and confusion

### Quick Start

**Check for ready work:**

```bash
bd ready --json
```

**Create new issues:**

```bash
bd create "Issue title" --description="Detailed context" -t bug|feature|task -p 0-4 --json
bd create "Issue title" --description="What this issue is about" -p 1 --deps discovered-from:bd-123 --json
```

**Claim and update:**

```bash
bd update <id> --claim --json
bd update bd-42 --priority 1 --json
```

**Complete work:**

```bash
bd close bd-42 --reason "Completed" --json
```

### Issue Types

- `bug` - Something broken
- `feature` - New functionality
- `task` - Work item (tests, docs, refactoring)
- `epic` - Large feature with subtasks
- `chore` - Maintenance (dependencies, tooling)

### Priorities

- `0` - Critical (security, data loss, broken builds)
- `1` - High (major features, important bugs)
- `2` - Medium (default, nice-to-have)
- `3` - Low (polish, optimization)
- `4` - Backlog (future ideas)

### Workflow for AI Agents

1. **Check ready work**: `bd ready` shows unblocked issues
2. **Create a branch for the task**: `git switch -c <bd-task-id>`
3. **Claim your task atomically**: `bd update <id> --claim`
4. **Work on it**: Implement, test, document
5. **Discover new work?** Create linked issue:
   - `bd create "Found bug" --description="Details about what was found" -p 1 --deps discovered-from:<parent-id>`
6. **Complete and merge**: `bd close <id> --reason "Done"`, then `git add -A && git commit -m "..."`, then `git switch main && git merge <branch> && git branch -d <branch>`
7. **Commit before next task**: never open/claim the next task before committing the previous one's work

**Pausing a task (work not finished):**

If you need to pause before completing a task, commit the partial work on the branch, push it, and switch to the new task's branch. Never leave uncommitted work on main or the branch when switching contexts.

```bash
git add -A && git commit -m "wip: <bd-task-id> partial work checkpoint"
git push -u origin <bd-task-id>
git switch -c <next-task-id>
```

When returning to the paused task, rebase or merge main, then continue.

```bash
git switch <paused-branch>
git rebase main
# continue working
```

### Quality
- Use `--acceptance` and `--design` fields when creating issues
- Use `--validate` to check description completeness

### Lifecycle
- `bd defer <id>` / `bd supersede <id>` for issue management
- `bd stale` / `bd orphans` / `bd lint` for hygiene
- `bd human <id>` to flag for human decisions
- `bd formula list` / `bd mol pour <name>` for structured workflows

### Auto-Sync

bd automatically syncs via Dolt:

- Each write auto-commits to Dolt history
- No manual export/import needed!

**Architecture in one line:** issues live in a local Dolt DB; sync uses `refs/dolt/data` on your git remote; `.beads/issues.jsonl` is a passive export. See https://github.com/gastownhall/beads/blob/main/docs/SYNC_CONCEPTS.md for details and anti-patterns.

### Important Rules

- ✅ Use bd for ALL task tracking
- ✅ Always use `--json` flag for programmatic use
- ✅ Link discovered work with `discovered-from` dependencies
- ✅ Check `bd ready` before asking "what should I work on?"
- ✅ Branch per task — create a feature branch for each bd issue, merge to main when done
- ✅ Commit between tasks — close and commit before claiming the next one
- ❌ Do NOT create markdown TODO lists
- ❌ Do NOT use external issue trackers
- ❌ Do NOT duplicate tracking systems

For more details, see README.md and docs/QUICKSTART.md.

## Session Completion

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds

<!-- END BEADS INTEGRATION -->


## Build & Test

```bash
# Install Ruby + JS deps
bundle install
npm install

# Database (creates, migrates, seeds with colleges/departments/subjects/users/etc.)
bin/rails db:prepare
bin/rails db:seed
bin/rails db:reset              # drop + db:prepare + db:seed

# Dev server (Rails + Tailwind watcher via Foreman)
bin/dev                         # http://localhost:3000

# Tests
bin/rails test                  # full Minitest suite (parallelized)
bin/rails test:system           # Capybara/Selenium system tests (optional)
bin/rails test test/models/user_test.rb                   # single file
bin/rails test test/integration/academic_tools_test.rb -n /quiz/   # by name

# Quality gates
bin/rubocop                     # Ruby style (omakase Rails)
bin/erb_lint --lint-all         # ERB templates
bin/brakeman --quiet --no-pager # Static security analysis
bin/bundler-audit               # Gem vuln audit
bin/importmap audit             # JS importmap audit

# Full local CI (runs all of the above in order)
bin/ci
```

## Architecture Overview

- **Monolith**: Rails 8.1 on Ruby 4.0.1, SQLite (primary + cache/queue/cable DBs).
- **HTTP layer** (`app/controllers/`): RESTful resourceful routes; nested under `subjects` for academic tools (materials, quizzes, assignments, schedules, attendances); top-level for `feed`, `chat_rooms` (with nested `messages`), `profile`; `namespace :admin` for the back office (colleges/departments/subjects/users/audit_logs).
- **Auth & Authz**: Rails 8 cookie-session auth via `Session` model + `Current.session` (`app/models/current.rb`); `allow_browser versions: :modern` and `stale_when_importmap_changes` set globally in `ApplicationController`. Pundit policies in `app/policies/` (one per resource, plus `ApplicationPolicy` + nested `Scope`).
- **Domain** (`app/models/`): hierarchical institution model `College → Department → Subject`, with `Enrollment` joining `User` (student/teacher) to `Subject`. Posts are polymorphic-scoped (`College`/`Department`/`Subject`/`nil` for global); `Notification`/`AuditLog` are polymorphic notifiables/auditable. Soft-delete via the `discard` gem (`Post`, `Message`).
- **Real-time**: Action Cable over Solid Cable — `app/channels/` (placeholder); broadcasts also fired from `Post` lifecycle callbacks.
- **Background work**: `NotificationJob` (`app/jobs/`) on Solid Queue.
- **Frontend**: Hotwire (Turbo Streams + Stimulus) with importmap; Tailwind CSS compiled by `tailwindcss-rails` (watched in dev). No custom SPA — server-rendered ERB.
- **I18n**: `config.i18n.available_locales = [:en, :ar]`, default `:en`. Locale resolved from `params[:locale]` → `cookies[:locale]` → `session[:locale]` → default in `ApplicationController#set_locale`. RTL handled in CSS via logical properties.
- **Storage**: Active Storage with local disk (`storage/`); `image_processing` for variants.

## Conventions & Patterns

- **Branch & commit**: GitHub Flow — short-lived branches off `main` (`feat/<scope>`, `fix/<scope>`); `bin/ci` must be green before merging.
- **Issue tracking**: every task goes through `bd` (beads). One branch per issue; commit and close before claiming the next.
- **Styling**: Ruby follows `rubocop-rails-omakase` (inherited in `.rubocop.yml`). ERB lint config in `.erb_lint.yml` enables only the Rubocop linter with selected `Layout/*` rules disabled.
- **Authorization**: every controller action that touches a record must go through Pundit (`include Pundit::Authorization` is already in `ApplicationController`); add a policy under `app/policies/<resource>_policy.rb` and use `authorize` / `policy_scope`. Unauth → `redirect_to root_path, alert: t("alerts.not_authorized")`.
- **Auth in tests**: use `sign_in_as(user)` from `test/test_helpers/session_test_helper.rb` in integration/controller tests; never hit the login form in tests.
- **Test data**: build test objects with FactoryBot (`create` / `build`) — no fixtures except a small `users.yml`. Traits encode roles (`:teacher`, `:admin`).
- **Soft-delete**: include `Discard::Model` and query with `.kept`; the feed scope (`Post.feed_for(user)`) is the reference example.
- **Polymorphic scoping**: when adding a notifiable/auditable, follow the `belongs_to :notifiable, polymorphic: true` / `:auditable, polymorphic: true` pattern already in `Notification` and `AuditLog`.
- **Locales**: never hard-code user-facing strings in controllers, models, or views — wrap with `t("...")` / `I18n.t("...")` and add the key to both `config/locales/en.yml` and `config/locales/ar.yml`.
- **Files & uploads**: validate size at the model layer (see `Message#attachments_size_valid`, 50 MB cap). Use Active Storage attachments (`has_many_attached` / `has_one_attached`).
- **Broadcasts**: real-time UI updates go through Turbo Streams from `after_create_commit` / `after_update_commit` / `after_destroy_commit` callbacks (see `Post#broadcast_*`).
- **Routes**: prefer nested resourceful routes inside `subjects` for academic tools; custom member/collection actions are acceptable when the verb is clear (e.g. `post :mark_read` on `feed`).
