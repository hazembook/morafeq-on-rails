# Morafeq (مرافق)

Morafeq is a modern, real-time academic companion monolith built on **Rails 8**. It is designed to act as a centralized, distraction-free portal for students, teachers, and administrators to communicate, collaborate, and manage academic resources without relying on public, ad-driven social media platforms.

Morafeq is built with a focus on speed, responsiveness, and clean aesthetics, delivering a desktop and mobile-friendly experience using **Hotwire (Turbo & Stimulus)** and **Tailwind CSS**.

---

## 🌟 Key Features

*   **🎓 Academic Tools & Analytics:**
    *   **Quizzes:** MCQ and True/False online forms with automatic point calculation and status toggles (Open, Closed, Locked).
    *   **Assignments:** Document/file submission worksheets supporting PDF, Word, PowerPoint, and images.
    *   **Timetable:** Dynamic, personalized day-by-day class schedule slots mapped to classrooms.
    *   **Attendance:** Inline session-by-session student attendance tracking (Present, Absent, Excused) with overview logs.
    *   **Academic Dashboard:** Detailed profile analytical metrics showing attendance rates, quiz averages, and file assignment scores.
*   **💬 Real-Time Chat System:**
    *   Dynamic messaging, private user-to-user DMs, and subject-specific chat rooms powered by **Solid Cable**.
    *   Supports text formatting, typing indicators, read receipts, message retraction (unsend within 5 minutes), and file attachments.
*   **📰 Feed:**
    *   Scoped academic announcements segmented by College, Department, or Subject tabs to eliminate announcement noise.
    *   Supports official flairs, pinned announcements, and infinite scrolling.
*   **📂 Materials Library:**
    *   Organized folder/file repository per subject with file size/type validations (max 50MB).
*   **🌐 Multi-Language & RTL Support:**
    *   Native multi-language localization (I18n) for **Arabic** and **English** with logical layout CSS properties for RTL stylesheet direction alignment.
*   **🏢 Multi-Institution Adaptability:**
    *   Extensible design that conforms dynamically to the terminology and structures of **Universities/Colleges (default)**, **Schools (K-12)**, **Bootcamps**, or **LMS Platforms**.

---

## 🛠️ Technology Stack

*   **Backend:** Ruby 4.0.1, Rails 8.1 Monolith
*   **Database:** SQLite (optimized with WAL mode and `busy_timeout` for concurrent requests)
*   **Frontend:** Hotwire (Turbo & Stimulus)
*   **Styling:** Tailwind CSS (responsive layouts, logical layout properties for RTL conversion)
*   **Real-time:** Solid Cable (WebSocket channel connection)
*   **Jobs & Queues:** Solid Queue (async background tasks)
*   **Cache:** Solid Cache

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed on your system:

*   **mise** — a dev tools version manager ([install guide](https://mise.jdx.dev/getting-started.html))
*   **SQLite3**

### Setup Installation

1.  **Install mise (if you don't have it):**
    ```bash
    curl https://mise.jdx.dev/install.sh | sh
    eval "$(~/.local/bin/mise activate)"
    ```

2.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/morafeq.git
    cd morafeq
    ```

3.  **Install Ruby and dependencies:**
    ```bash
    mise install
    bundle install
    ```

4.  **Prepare the database (creates tables, runs migrations, and inserts seed data):**
    ```bash
    bin/rails db:prepare
    bin/rails db:seed
    ```
    *Note: The seed script populates colleges, departments, subjects, students, teachers, assignments, and mock chat rooms to start testing right away.*

5.  **Start the development server:**
    ```bash
    bin/dev
    ```
    This starts both the Rails server and the Tailwind CSS compiler. You can now access the app at `http://localhost:3000`.

### Troubleshooting

If `mise install` does not automatically read `.ruby-version`, run:
```bash
mise install ruby@4.0.1
```

---

## 🧪 Demo Accounts

After running `bin/rails db:seed`, you can sign in with any of these accounts (password: `password123` for all):

| Role | Email | Can do |
|---|---|---|
| **Admin** | `admin@morafeq.edu` | Full access to `/admin` — manage colleges, departments, subjects, users |
| **Teacher** | `ahmed@morafeq.edu` | Create quizzes, assignments, take attendance, grade submissions |
| **Teacher** | `sara@morafeq.edu` | Same as above |
| **Student** | `omar@morafeq.edu` | View subjects/submissions, take quizzes, chat, browse feed |
| **Student** | `layla@morafeq.edu` | Same as above |
| **Moderator** | `moderator@morafeq.edu` | Moderate posts and comments across the feed |
| **TA** | `ta@morafeq.edu` | Assist teachers with grading and course materials |

> ⚠️ **Staging instance**: `morafeq.hazembook.com` runs the latest code from `main` on a development VM. It uses SQLite and seeded demo data — **not production-ready**. Data may be reset at any time.

---

## 🧪 Testing & Linting

*   **Run the test suite:**
    ```bash
    bin/rails test
    ```
*   **Run system tests (requires Chrome/Chromium):**
    ```bash
    bin/rails test:system
    ```
*   **Run linter and security audits:**
    ```bash
    bin/rubocop
    bundle exec erb_lint --lint-all
    bin/brakeman --quiet --no-pager
    bin/bundler-audit
    bin/importmap audit
    ```
*   **Run all quality gates:**
    ```bash
    bin/ci
    ```

---

## 🌿 Contribution & Workflow

We use the **GitHub Flow** branching model:

*   `main` is the stable integration branch.
*   Create short-lived feature/bugfix branches off `main` (e.g., `feat/profile-stats`, `fix/chat-scroll`).
*   Verify code quality with `bin/ci` and ensure the test suite is green before merging.

Issues and feature requests are tracked via **bd (beads)** — a Git-friendly, dependency-aware issue tracker integrated into this repository.

---

## 📄 License

This project is licensed under the **Waqf Public License 2.0**. See the [LICENSE](LICENSE) file for the full license text.
