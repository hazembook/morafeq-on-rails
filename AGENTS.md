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
bd close bd-42 --reason "Substantive summary of what was fixed/why" --json
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
6. **Commit and present a handoff summary**, then **stop and wait for explicit human confirmation**:
   - `git add -A && git commit -m "..."` with a `Refs: <id>` footer
   - Present: branch name, key commits, diff highlights, quality-gate status, suggested merge message
   - Do **not** merge, push, or close the bd task until the human says "go ahead" (or equivalent)
7. **After explicit confirmation, run the publish steps** (see Session Completion): `bd close` on the feature branch with a substantive reason, commit the JSONL export, then fast-forward `main`, push to `origin main`, delete local branch
8. **Commit before next task**: never open/claim the next task before handing off the previous one.

Rationale: the project is single-owner, so feature branches stay local. The agent works on isolated, reproducible steps; the human reviews the diff and explicitly signs off before anything touches `main` on `origin`. The explicit "go ahead" is the gate — the agent never assumes approval from a "thanks" or "looks good" alone. When more contributors join, add PRs by pushing the feature branch to `origin` and letting the human open the PR.

### Human-in-the-Loop Split

- **Agent** owns: check bd, claim, branch, implement, test, commit, run quality gates, present handoff summary
- **Human** owns: review diff, give explicit confirmation (e.g., "go ahead")
- **After confirmation, agent** owns: `bd close` on the feature branch with a substantive reason, commit the JSONL export, fast-forward `main`, push to `origin main`, delete local feature branch

### Pre-change Workflow (Direct Requests & Untracked Work)

The standard workflow above assumes the agent is picking from `bd ready`. For **direct requests** from the user, **work that isn't tracked**, or **even for an already-tracked task**, follow this checklist before writing any code:

1. **Review and debate the request.** If the change is non-trivial, the approach is unclear, or there's a tradeoff to weigh, surface it first — propose options, cite constraints, and confirm direction. Do not assume the literal request is the best path.
2. **Check bd for related work:** `bd ready --json` and `bd list --json`. If an existing issue already covers the request (even partially), use it: claim with `bd update <id> --claim` and link new findings via `--deps discovered-from:<id>`. If nothing matches, create a new task with `bd create` (clear title, type, priority, description).
3. **Never work on `main` directly — always branch, even for tracked work.** This applies whether the task was pre-existing or just created. The flow is:
   - Commit the bd state change (claim or create, plus any `--deps` linkage) so the bd auto-export to `.beads/issues.jsonl` is in git history
   - Branch from `main` with `git switch -c <bd-id>`
   - Implement, run quality gates on the branch, commit with a `Refs: <id>` footer in the work commit
   - Present a handoff summary and **stop and wait for explicit human confirmation** before any merge, push, or bd close — the agent never assumes approval from a "thanks" or "looks good" alone
   - After the human says "go ahead" (or equivalent), execute the publish steps in Session Completion

**Pausing a task (work not finished):**

If you need to pause before completing a task, commit the partial work on the branch (local only), and switch to the new task's branch. Never leave uncommitted work on main or the branch when switching contexts.

```bash
git add -A && git commit -m "wip: <bd-task-id> partial work checkpoint"
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

- Use bd for substantive work; trivial doc-only changes (workflow prose, comment policy, this file) may skip bd
- Always use `--json` flag for programmatic use
- Link discovered work with `discovered-from` dependencies
- Check `bd ready` before asking "what should I work on?"
- Branch per task — create a feature branch for each change, merge to main when done
- Commit between tasks — close and commit before claiming the next one
- Do NOT create markdown TODO lists
- Do NOT use external issue trackers
- Do NOT duplicate tracking systems

For more details, see README.md and docs/QUICKSTART.md.

## Session Completion

This section describes the **explicit-confirm publish flow**: the agent prepares the work, the human reviews and gives explicit "go ahead", and only then does the agent touch `main` on `origin`. Feature branches stay local — only `main` is pushed.

### Agent handoff (end of session)

1. **File issues for remaining work** — anything you noticed but didn't fix
2. **Run quality gates** on the branch — `bin/ci` (or the relevant subset)
3. **Present a handoff summary** to the human: branch name, key commits, diff highlights, quality-gate status, suggested merge commit message
4. **Stop and wait for explicit confirmation** — the agent does nothing further until the human says "go ahead" (or equivalent). A "thanks" or "looks good" is **not** approval.

### Human review (gate)

5. **Review the diff on the branch** (and the handoff summary)
6. **Give explicit confirmation** — say "go ahead" (or "merge it", "publish", "ship it", or any unambiguous signal). If you want changes, say "rework X" and the agent picks the branch back up.

### Agent publish (only after explicit confirmation)

7. **Close the task on the feature branch** before merging, then commit the JSONL export as the final branch commit:
   ```bash
   bd close <id> --reason "<substantive resolution summary>" --json
   git add .beads/ && git commit -m "chore(bd): close <id> — <short summary>"
   ```
   The `--reason` must be a substantive summary of what was fixed and why, not git bookkeeping.
   The commit message should include a brief human-readable description of what was done (e.g. "add file type and size model tests") so `git log --oneline` is informative.
   After this, `git status` on the feature branch is clean.

8. **Fast-forward `main`** (or rebase the branch first for a cleaner linear history):
   ```bash
   git switch <bd-id>          # on the feature branch
   git rebase main             # optional, replays work on top of current main
   git switch main
   git merge <bd-id>           # fast-forward — no merge commit
   ```
9. **Push `main` to `origin`**:
   ```bash
   git pull --rebase origin main
   git push origin main
   git status             # MUST show "up to date with 'origin/main'"
   ```
10. **Delete the local feature branch**:
    ```bash
    git branch -d <bd-id>
    ```
    `git status` returns clean — no dangling `.beads/` changes after push.

**CRITICAL RULES:**
- The agent **never** runs `git push origin main` without explicit human confirmation
- The agent **never** force-pushes (`--force` / `--force-with-lease`) — only the human does, and only after a history rewrite
- The agent **never** merges to `main` without explicit human confirmation
- The agent **never** pushes feature branches — only `main` is pushed
- A "thanks" or "looks good" is **not** approval — the agent waits for an unambiguous "go ahead"
- If the agent runs into a git state it can't recover from, it stops, commits a `wip:` checkpoint, and hands off to the human for the next move

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
- **Commit messages**: default to a single-line subject in Conventional Commits form (`<type>(<scope>): <subject>`), imperative mood, ≤ 72 chars, no trailing period. Add a body **only** when the bd issue or the file itself doesn't already explain the WHY — e.g. the implementation deviates from the plan, there's a non-obvious tradeoff, or it's a workaround for an upstream bug. For trivial doc-only changes to this file, the diff is self-explanatory; default to a one-liner with no body. When you do write a body, it answers WHY, not WHAT (the diff shows the WHAT). Use the footer for `Refs: bd-42` linkage or `BREAKING CHANGE:` notes. For AI agents: hard cap at ~6 lines of body; if it doesn't fit, split the commit.
- **Code comments & documentation**: keep code self-documenting and let `bd` track future work. **Allowed**: section labels in long files (ERB `<%# ... %>` and Ruby `#`); one-line intent flags for non-obvious side effects (see `ChatRoomsController#mark_seen`, `Post#broadcast_*`); Ruby magic comments (`# frozen_string_literal: true`); the Rails scaffold leftovers in `app/jobs/application_job.rb`. **Forbidden**: `TODO`/`FIXME`/`HACK`/`XXX`/`NOTE` markers (use `bd`); `=begin/=end` block comments; HTML `<!-- -->` in ERB; YARD/RDoc doc blocks on app code; commented-out code (anything not in Rails default scaffold); "what" narration of the diff; self-justification. **Acid test**: deleting the comment should leave the next reader confused. If it doesn't, delete it.
