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

### Pre-change Workflow (Direct Requests & Untracked Work)

The standard workflow above assumes the agent is picking from `bd ready`. For **direct requests** from the user, **work that isn't tracked**, or **even for an already-tracked task**, follow this checklist before writing any code:

1. **Review and debate the request.** If the change is non-trivial, the approach is unclear, or there's a tradeoff to weigh, surface it first — propose options, cite constraints, and confirm direction. Do not assume the literal request is the best path.
2. **Check bd for related work:** `bd ready --json` and `bd list --json`. If an existing issue already covers the request (even partially), use it: claim with `bd update <id> --claim` and link new findings via `--deps discovered-from:<id>`. If nothing matches, create a new task with `bd create` (clear title, type, priority, description).
3. **Never work on `main` directly — always branch, even for tracked work.** This applies whether the task was pre-existing or just created. The flow is:
   - Commit the bd state change (claim or create, plus any `--deps` linkage) so the bd auto-export to `.beads/issues.jsonl` is in git history
   - Branch from `main` with `git switch -c <bd-id>`
   - Implement, run quality gates, commit with a `Refs: <id>` footer in the work commit
   - Merge to `main` with `--no-ff` (per project convention), then `git branch -d` and `git push origin --delete` the branch (and `git push gihub` / `git push gilab` — see Session Completion)
   - `bd close <id> --reason "..."` with a reference to the merge commit

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
4. **PUSH TO REMOTE** - This is MANDATORY. The project has three remotes — push to all of them:
   ```bash
   git pull --rebase
   git push origin main   # codeberg (canonical)
   git push gihub main    # github mirror
   git push gilab main    # gitlab mirror
   git remote -v          # MUST show all three at the same tip
   ```
   The remote names `gihub` / `gilab` are typos preserved for history; rename via `git remote rename` if desired.
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
# Install Ruby deps (JS is managed by importmap, no node_modules)
bundle install

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
bundle exec erb_lint --lint-all # ERB templates (no binstub)
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

- **Branch & commit**: feature-branch flow — short-lived branches off `main` (`feat/<scope>`, `fix/<scope>`); `bin/ci` must be green before merging. See the BEADS INTEGRATION section for issue tracking + branch-per-issue workflow.
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
- **Commit messages**: default to a single-line subject in Conventional Commits form (`<type>(<scope>): <subject>`), imperative mood, ≤ 72 chars, no trailing period. Add a body **only** when the bd issue doesn't already explain the WHY — e.g. the implementation deviates from the plan, there's a non-obvious tradeoff, or it's a workaround for an upstream bug. When you do write a body, it answers WHY, not WHAT (the diff shows the WHAT). Use the footer for `Refs: bd-42` linkage or `BREAKING CHANGE:` notes. For AI agents: hard cap at ~6 lines of body; if it doesn't fit, split the commit.
- **Code comments & documentation**: keep code self-documenting and let `bd` track future work. **Allowed**: section labels in long files (ERB `<%# ... %>` and Ruby `#`); one-line intent flags for non-obvious side effects (see `ChatRoomsController#mark_seen`, `Post#broadcast_*`); Ruby magic comments (`# frozen_string_literal: true`); the Rails scaffold leftovers in `app/jobs/application_job.rb`. **Forbidden**: `TODO`/`FIXME`/`HACK`/`XXX`/`NOTE` markers (use `bd`); `=begin/=end` block comments; HTML `<!-- -->` in ERB; YARD/RDoc doc blocks on app code; commented-out code (anything not in Rails default scaffold); "what" narration of the diff; self-justification. **Acid test**: deleting the comment should leave the next reader confused. If it doesn't, delete it.
