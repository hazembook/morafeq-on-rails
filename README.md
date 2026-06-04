# Morafeq (مرافق)

Morafeq is a modern, real-time academic companion monolith built on **Rails 8**. It is designed to act as a centralized portal for students, teachers, and administrators to communicate, collaborate, and manage academic resources.

Morafeq is built with a focus on speed, responsiveness, and clean aesthetics, delivering a desktop and mobile-friendly experience using **Hotwire (Turbo & Stimulus)** and **Tailwind CSS**.

---

## 🌟 Key Features

*   **🎓 Academic Tools & Analytics:**
    *   **Quizzes:** MCQ and True/False online forms with automatic point calculation and status toggles (Open, Closed, Locked).
    *   **Assignments:** Document/file submission worksheets supporting PDF, Word, PowerPoint, and images.
    *   **Timetable Schedule:** Day-by-day class schedule slots mapped to classrooms.
    *   **Attendance:** Inline session-by-session student attendance tracking (Present, Absent, Excused) with overview logs.
    *   **Academic Dashboard:** Detailed profile analytical metrics showing attendance rates, quiz averages, and file assignment scores.
*   **💬 Real-Time Chat System:**
    *   Dynamic messaging, private user-to-user DMs, and subject-specific chat rooms powered by **Solid Cable**.
    *   Supports text formatting, typing indicators, read receipts, message retraction (unsend within 5 minutes), and file attachments.
*   **📰 Interactive Feed:**
    *   Announcements scoped by College, Department, or Subject.
    *   Supports official flairs, pinned announcements, and infinite scrolling.
*   **📂 Materials Library:**
    *   Organized folder/file repository per subject with file size/type validations (max 50MB).
*   **🌐 Multi-Language & RTL Support:**
    *   Native multi-language localization (I18n) for **Arabic** and **English** with RTL stylesheet direction alignment.
*   **🏢 Multi-Institution Adaptability:**
    *   Extensible design that conforms dynamically to the terminology and structures of **Universities/Colleges (default)**, **Schools (K-12)**, **Bootcamps**, or **LMS Platforms**.

---

## 🛠️ Technology Stack

*   **Backend:** Ruby 3.x, Rails 8.0 Monolith
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
*   **Ruby:** `3.3.x` or higher
*   **SQLite3**
*   **Node.js / npm** (for asset processing)

### Setup Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/morafeq.git
    cd morafeq
    ```

2.  **Install dependencies:**
    ```bash
    bundle install
    npm install
    ```

3.  **Prepare the database (creates tables, runs migrations, and inserts seed data):**
    ```bash
    bin/rails db:prepare
    bin/rails db:seed
    ```
    *Note: The seed script populates colleges, departments, subjects, students, teachers, assignments, and mock chat rooms to start testing right away.*

4.  **Start the development server:**
    ```bash
    bin/dev
    ```
    This starts both the Rails server and the Tailwind compiler. You can now access the app at `http://localhost:3000`.

---

## 🧪 Testing & Linting

We maintain a high level of code quality and regression prevention.

*   **Run the test suite:**
    ```bash
    bundle exec rails test
    ```
*   **Run linter and security audits:**
    ```bash
    bundle exec rubocop
    bundle exec brakeman
    bundle exec erb_lint --lint-all
    ```

---

## 🌿 Git branching conventions

We use the **GitHub Flow** branching model:
*   `main` is the stable integration branch.
*   Create short-lived feature/bugfix branches off `main` (e.g., `feat/profile-stats`, `fix/chat-scroll`).
*   Verify code quality and ensure the test suite is green before squash-merging back into `main`.

---

## 📄 License
This project is proprietary and confidential. All rights reserved.
