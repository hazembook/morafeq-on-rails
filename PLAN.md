# Project Plan: Morafeq (Rails 8 Monolith)

## 1. Executive Summary
Morafeq is a university companion app built as a **Rails 8 Monolith**. This approach prioritizes development speed, maintainability, and standard web technologies while delivering a mobile-app-like experience via **PWA** initially, with a clear upgrade path to **Hotwire Native** for iOS/Android stores.

## 2. Architecture & Tech Stack

### Core Stack
- **Framework:** Rails 8.0 (Ruby 3.x)
- **Database:** SQLite (Production-ready via WAL mode)
- **Frontend:** Hotwire (Turbo & Stimulus)
- **Styling:** Tailwind CSS (Mobile-first utility classes)
- **Real-time:** Solid Cable (WebSocket updates for Chat & Notifications)
- **Background Jobs:** Solid Queue (File processing, emails, notification delivery)
- **Caching:** Solid Cache
- **Deployment:** Kamal 2 (Docker-based, deploy anywhere)

### Quality & Safety
- **Testing:** Minitest (Rails default) + FactoryBot + Shoulda Matchers
- **Authorization:** Pundit (policy objects per resource)
- **Code Quality:** RuboCop, Brakeman (security), ERB Lint

### Mobile Strategy
1. **Phase 1 (PWA):** Responsive, installable via `manifest.json`. Lives on home screen.
2. **Phase 2 (Hotwire Native):** (Future) Wrap Rails views in iOS/Android Turbo Native shell for push notifications and native navigation.

## 3. User Roles & Permissions
Single `User` model with `role` enum. Authorization enforced via Pundit policies.

1. **Student:**
   - View Feed (filtered by their scope).
   - Chat in public subject rooms and private DMs.
   - Download materials for enrolled subjects.
2. **Teacher:**
   - All Student capabilities.
   - **Posts:** Create posts (with optional "Official" flair); pin/unpin posts in their subjects.
   - **Materials:** Upload/manage materials for their subjects.
   - **Chat:** Moderate (delete) messages in their subject rooms.
3. **Super Admin:**
   - Full CRUD via `/admin` back-office (Users, Subjects, Departments, Colleges, Global Settings, Task Distributions).
   - Access to audit logs.
   - Sees only the admin panel (no feed, subjects, chats).
4. **Teacher:**
   - All Student capabilities.
   - **Posts:** Create posts (with optional "Official" flair); pin/unpin posts in their subjects.
   - **Materials:** Upload/manage materials for their subjects.
   - **Chat:** Moderate (delete) messages in their subject rooms.
   - Can assign TAs to their own subjects.

5. **Moderator:**
   - Assigned to a **College** or **Department** via TaskDistribution.
   - Can manage **posts** scoped to that College/Department.
   - No access to materials, quizzes, attendance, or chat.

6. **Teaching Assistant (TA):**
   - Assigned to a **Subject** via TaskDistribution by the subject teacher or super admin.
   - Granular permissions per Subject (posts, materials, quizzes, schedules, attendance, chat) — controlled by TaskDistribution flags.

## 4. Database Schema

### Users & Auth
- `users`: `email`, `password_digest`, `role` (enum: 0 student, 1 teacher, 2 admin), `full_name`, `bio`.
- *Attachments:* `avatar` (ActiveStorage).
- *Devices:* `user_devices` for push notification tokens (future Hotwire Native).

### Academic Structure
- `colleges`: `name`
- `departments`: `name`, `college_id`
- `subjects`: `name`, `code`, `department_id`, `teacher_id` (User)
- `enrollments`: `user_id`, `subject_id` (join table, unique constraint)

### Social & Content
- `posts`:
  - `content`: text
  - `author_id`: User
  - `scope_type`: String (Polymorphic: 'College', 'Department', 'Subject')
  - `scope_id`: Integer
  - `pinned`: boolean (teachers can pin)
  - `deleted_at`: datetime (soft delete via `discard`)
  - *Attachments:* images/files (ActiveStorage).
- `materials`:
  - `title`: string
  - `subject_id`: references Subject
  - `deleted_at`: datetime (soft delete)
  - *Attachments:* file (PDFs, PPTs, etc.).

### Chat System
- `chat_rooms`: `name`, `is_private` (bool), `subject_id` (optional, for class groups)
- `chat_participants`: `user_id`, `chat_room_id`
- `messages`: `content`, `user_id`, `chat_room_id`
  - `deleted_at`: datetime (soft delete — "unsend" within 5 min)
  - *Attachments:* images/files (ActiveStorage, optional).

### Academic Tools
- `quizzes`: `title`, `subject_id`, `due_at` (datetime), `total_points` (integer)
  - `quiz_questions`: `quiz_id`, `question` (text), `points` (integer)
  - `quiz_answers`: `quiz_question_id`, `user_id`, `answer` (text), `score` (integer, nullable)
- `schedules`: `subject_id`, `day` (integer, 0-6), `start_time` (time), `end_time` (time), `room` (string)
- `attendances`: `user_id`, `subject_id`, `date` (date), `status` (string: present/absent/excused), `recorded_by` (User)

### Task Distribution (Moderators & TAs)
- `task_distributions`:
  - `user_id`: FK (moderator or TA)
  - `scope_type`: string (polymorphic — "College", "Department", "Subject")
  - `scope_id`: integer
  - `assigned_by_id`: FK User (teacher for subjects, super admin for college/dept)
  - `manage_posts`: boolean
  - `manage_materials`: boolean (subject-only)
  - `manage_quizzes`: boolean (subject-only)
  - `manage_schedules`: boolean (subject-only)
  - `manage_attendance`: boolean (subject-only)
  - `manage_chat`: boolean (subject-only)

### Notifications
- `notifications`:
  - `recipient_id`: User
  - `actor_id`: User (who triggered it)
  - `action`: string (e.g. "posted", "messaged", "uploaded")
  - `notifiable_type` / `notifiable_id`: Polymorphic (Post, Message, Material)
  - `read_at`: datetime (nullable)
  - Delivery via Solid Queue + Solid Cable for real-time badge updates.

### Task Distribution (Moderators & TAs)
- `task_distributions`:
  - `user_id`: FK (moderator or TA)
  - `scope_type`: string (polymorphic — "College", "Department", "Subject")
  - `scope_id`: integer
  - `assigned_by_id`: FK User (teacher for subjects, super admin for college/dept)
  - `manage_posts`: boolean
  - `manage_materials`: boolean (subject-only)
  - `manage_quizzes`: boolean (subject-only)
  - `manage_schedules`: boolean (subject-only)
  - `manage_attendance`: boolean (subject-only)
  - `manage_chat`: boolean (subject-only)

### Audit Log
- `audit_logs`:
  - `action`: string
  - `auditable_type` / `auditable_id`: Polymorphic
  - `user_id`: who performed it
  - `changes`: jsonb (before/after diff)

## 5. Implementation Roadmap

### Phase 1: Setup & Foundations
- [x] Initialize Rails 8 app with `rails new morafeq --css tailwind`
- [ ] Setup RuboCop, Brakeman, ERB Lint config
- [x] Setup PWA: `manifest.json`, icons, service worker
- [x] Implement Authentication (Rails 8 `generate authentication`)
- [x] Add password reset flow (included in generator)
- [x] Create `User` model with Role enum (`student`/`teacher`/`admin`) and Avatar (ActiveStorage)
- [x] Setup FactoryBot + Shoulda Matchers; write User model tests
- [ ] Setup dotenv for local env vars, Rails credentials for secrets
- [x] Write comprehensive seed data (`db/seeds.rb`) — demo colleges, departments, subjects, users

### Phase 2: Academic & Admin Core
- [x] Create Models: `College`, `Department`, `Subject`, `Enrollment`
- [x] Add Pundit policies for all resources
- [x] Write model tests (validations, associations, scopes)
- [x] **Admin Back-office (`/admin`):**
  - Build CRUD for Colleges, Departments, Subjects
  - Allow Admins to assign Teachers to Subjects
  - Admin audit log viewer
- [x] **Teacher capabilities (inline in app):**
  - Subject detail page shows "Upload Material" and "Manage Files" buttons for the assigned teacher
  - "My Subjects" tab in nav lists subjects the teacher teaches, with quick actions
  - No separate `/teacher` dashboard — teacher actions live in the main app UI
- [ ] Write system tests for admin flows + teacher inline actions

### Phase 3: The Feed (Home)
- [x] Create `Post` model with polymorphic scope, soft delete (`discard`)
- [x] Implement feed algorithm:
  - Student sees posts scoped to:
    1. Their enrolled Subjects
    2. The Departments those Subjects belong to
    3. The Colleges those Departments belong to
  - Teachers additionally see posts in subjects they teach (even if not enrolled)
  - Admin sees all
- [x] UI: Mobile-style Feed with Infinite Scroll (Turbo Frames + pagination)
- [x] Post creation (Teachers & Admins only): Compose posts scoped to their subjects, with optional "Official" flair toggle
- [x] Pinned posts at top of feed (teachers can pin in their subjects)
- [ ] Add file upload field to post composer (model supports attachments, form missing)
- [ ] Write tests for feed scoping logic (model + system)

### Phase 4: Materials System
- [x] Implement File Uploads (ActiveStorage) for Teachers
  - [x] Allowed types: PDF, PPT, DOCX, images
  - [x] File size validation (e.g., 50MB max)
- [x] Implement File Browser/Download for Students (per enrolled subject)
- [ ] Implement search via SQLite FTS5 virtual table
- [ ] Write system tests for upload/download flows

### Phase 5: Real-time Chat
- [x] Setup Solid Cable
- [x] Create Public Rooms (auto-created per Subject via `after_create` callback)
- [ ] Create Private DMs (User-to-User, created on first message)
- [x] UI: Chat Interface with:
  - [ ] Auto-scroll to bottom on load / new message
  - [x] Live append via Turbo Streams from Solid Cable
  - [ ] Typing indicators (via Cable)
  - [ ] File/image attachment support in messages
  - [x] "Unsend" within 5 minutes (soft delete)
  - [ ] Read receipts (seen_by tracking)
- [ ] Chat push notifications via Notifications system
- [ ] Moderation: Teachers can delete messages in their subject rooms
- [ ] Write system tests + channel tests

### Phase 6: Academic Tools
- [ ] **Quiz system (structured model):**
  - Quiz model with title, subject, due date, total points
  - QuizQuestion model (question text, points)
  - QuizAnswer model (user submission, teacher-assigned score)
  - Teacher creates quizzes for their subjects
  - Students submit answers, view grades
  - Auto-calc total score, show on profile
- [ ] **Schedule / Timetable:**
  - Schedule model (subject, day, start/end time, room)
  - Weekly timetable view per subject
  - Teacher/admin manages schedule
- [ ] **Attendance tracking:**
  - Attendance model (user, subject, date, status, recorded_by)
  - Teacher marks present/absent per session
  - Students view attendance on profile
  - Admin can view/edit any attendance
- [ ] Write tests

### Phase 7: Task Distribution & Role Expansion
- [ ] Add `moderator` and `ta` roles to User enum
- [ ] **TaskDistribution model:**
  - Polymorphic scope (College, Department, Subject)
  - `assigned_by_id` tracks who granted the assignment
  - Per-action permission flags (posts, materials, quizzes, schedules, attendance, chat)
- [ ] **Super Admin** — restricted to admin panel only (no feed/subjects/chats nav)
- [ ] **Moderator** — assigned to College or Department, manages posts only
- [ ] **Teaching Assistant** — assigned to Subject by teacher or super admin, granular permissions
- [ ] Teachers can assign TAs to their own subjects (creates TaskDistribution)
- [ ] Super admin manages all TaskDistributions via `/admin/task_distributions`
- [ ] Update Pundit policies for all new roles
- [ ] Seed moderator, TA, and task_distribution data
- [ ] Write tests

### Phase 8: Notifications System
- [ ] Create `Notification` model (polymorphic)
- [ ] Integration points:
  - New post in student's scope → notify enrolled students
  - New material uploaded → notify enrolled students
  - New message in DM → notify recipient
  - Teacher pins a post → notify enrolled students
- [ ] UI: Notification bell in navbar with unread badge (Turbo Streams via Solid Cable)
- [ ] Notification dropdown / page showing recent unread & all
- [ ] Mark as read (individual + "mark all read")
- [ ] Use Solid Queue for async notification delivery
- [ ] Write tests

### Phase 9: Search
- [ ] Add SQLite FTS5 virtual tables for:
  - Posts (full-text on content)
  - Subjects (name + code)
  - Materials (title)
- [ ] Global search bar in header
- [ ] Results grouped by type (Subjects, Posts, Materials)
- [ ] Write tests

### Phase 10: Polish & Deploy
- [ ] Mobile Polish:
  - Bottom navigation bar (responsive: sidebar on desktop, bottom tabs on mobile)
  - Touch targets >= 44px
  - Safe-area insets (viewport `env(safe-area-inset-*)`)
  - Pull-to-refresh via Stimulus
  - Offline fallback page (service worker)
- [ ] Production Setup:
  - Dockerfile (multi-stage: builder + production)
  - Kamal 2 config (`config/deploy.yml`)
  - SQLite WAL + `busy_timeout` config for concurrency
  - Solid Queue dashboard mounted at `/jobs` (admin-only)
  - **Sentry:** Add `sentry-ruby` and `sentry-rails` gems; configure DSN via env var
- [ ] CI/CD Pipeline:
  - Push repo to GitHub
  - Setup GitHub Actions: `rubocop`, `brakeman`, `rails test:all`, `rails test:system`
  - On green → Kamal deploy
- [ ] Deploy to VPS via Kamal
- [ ] Final smoke tests post-deploy

## 6. Git Workflow

### Branching Model
```
main          ─── Production releases. Only merged from `develop`.
  develop     ─── Integration branch. Feature branches PR here.
    feat/xxx  ─── New features. Branch off `develop`.
    fix/xxx   ─── Bug fixes. Branch off `develop`.
    chore/xxx ─── Tooling, config, refactors. Branch off `develop`.
```

### Convention
- **Branch names:** `feat/feed-scoping`, `fix/chat-scroll`, `chore/rubocop-rules`
- **Commits:** Atomic — one logical change per commit. Prefix with type:
  - `feat: add post pinning for teachers`
  - `fix: prevent empty message send in chat`
  - `chore: add rubocop rails config`
  - `test: add feed scoping model tests`
- **PRs:** squash-merge into `develop`. Keep history clean — no WIP or fixup commits on `develop`.

### Local First
- `rails new morafeq --css tailwind` auto-initializes a Git repo (no initial commit). Make the first commit yourself with the scaffolded app on `main`, then create a `develop` branch and work from there.
- All development happens locally. No CI required until Phase 10.
- Run `rails test` and `rubocop` before committing.
- Use `rails db:seed` to reset demo data as needed.
