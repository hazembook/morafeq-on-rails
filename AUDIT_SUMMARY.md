# Audit Summary — Saved 2026-06-12

## Branch: `fix/audit-001`

## Security Status
- brakeman: 0 warnings ✅
- bundler-audit: 0 CVEs ✅
- importmap audit: 0 vulns ✅

---

## Open Tasks (in priority order)

### P1: `morafeq-dw5` — Message content DB constraint violation
**File:** `app/models/message.rb:10`
`content` column is NOT NULL, but validation allows blank when attachments present.
Sending an attachment-only message crashes with DB constraint error.
Fix: set default empty string or add `before_validation` callback.

### P2: `morafeq-07k` — Duplicate private chat room race condition
**File:** `app/models/chat_room.rb` (find_or_create_private)
No DB-level unique constraint guards against concurrent duplicate private rooms.

### P3: `morafeq-iyj` — 26 ERB lint errors
7 files, 2 rule types:
- `Layout/SpaceInsideArrayLiteralBrackets`: `admin/task_distributions/_form.html.erb`, `feed/show.html.erb`
- `Style/StringLiterals`: `chat_rooms/_sidebar_room.html.erb`, `chat_rooms/_typing_indicator.html.erb`, `chat_rooms/show.html.erb`, `feed/_post.html.erb`, `layouts/application.html.erb`

### P3: `morafeq-0u2` — Missing audit_logs polymorphic index
Add migration for `[auditable_type, auditable_id]` on audit_logs.

### P4: `morafeq-1r3` — Duplicate ALLOWED_TYPES constants
Identical arrays in Material, Assignment, AssignmentSubmission.
Extract to `file_upload_constants.rb` initializer.

---

## How to resume
```bash
git switch fix/audit-001
bd ready --json          # see unblocked tasks
bd update <id> --claim   # claim a task
# work, commit with Refs: <id>
```

Run quality gates: `bin/ci` before merging.
