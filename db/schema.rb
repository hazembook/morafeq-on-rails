# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_04_153524) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "assignment_submissions", force: :cascade do |t|
    t.integer "assignment_id", null: false
    t.datetime "created_at", null: false
    t.text "feedback"
    t.integer "score"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["assignment_id"], name: "index_assignment_submissions_on_assignment_id"
    t.index ["user_id"], name: "index_assignment_submissions_on_user_id"
  end

  create_table "assignments", force: :cascade do |t|
    t.boolean "closed", default: false, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "due_at", null: false
    t.boolean "locked", default: false, null: false
    t.integer "subject_id", null: false
    t.string "title", null: false
    t.integer "total_points", default: 100, null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_assignments_on_subject_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.integer "recorded_by_id", null: false
    t.string "status", null: false
    t.integer "subject_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["recorded_by_id"], name: "index_attendances_on_recorded_by_id"
    t.index ["subject_id"], name: "index_attendances_on_subject_id"
    t.index ["user_id", "subject_id", "date"], name: "index_attendances_on_user_id_and_subject_id_and_date", unique: true
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.string "action"
    t.integer "auditable_id"
    t.string "auditable_type"
    t.datetime "created_at", null: false
    t.text "record_changes"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "chat_participants", force: :cascade do |t|
    t.integer "chat_room_id", null: false
    t.datetime "created_at", null: false
    t.integer "last_read_message_id"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["chat_room_id"], name: "index_chat_participants_on_chat_room_id"
    t.index ["user_id", "chat_room_id"], name: "index_chat_participants_on_user_id_and_chat_room_id", unique: true
    t.index ["user_id"], name: "index_chat_participants_on_user_id"
  end

  create_table "chat_rooms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_private", default: false, null: false
    t.string "name", null: false
    t.integer "subject_id"
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_chat_rooms_on_subject_id"
  end

  create_table "colleges", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_colleges_on_name", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "post_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "departments", force: :cascade do |t|
    t.integer "college_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["college_id"], name: "index_departments_on_college_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "subject_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["subject_id"], name: "index_enrollments_on_subject_id"
    t.index ["user_id", "subject_id"], name: "index_enrollments_on_user_id_and_subject_id", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "materials", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.integer "subject_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_materials_on_discarded_at"
    t.index ["subject_id"], name: "index_materials_on_subject_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "chat_room_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["chat_room_id"], name: "index_messages_on_chat_room_id"
    t.index ["discarded_at"], name: "index_messages_on_discarded_at"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "author_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.boolean "pinned", default: false, null: false
    t.integer "scope_id"
    t.string "scope_type"
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["discarded_at"], name: "index_posts_on_discarded_at"
    t.index ["scope_type", "scope_id"], name: "index_posts_on_scope_type_and_scope_id"
  end

  create_table "quiz_answers", force: :cascade do |t|
    t.text "answer", null: false
    t.datetime "created_at", null: false
    t.integer "quiz_question_id", null: false
    t.integer "score"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["quiz_question_id"], name: "index_quiz_answers_on_quiz_question_id"
    t.index ["user_id"], name: "index_quiz_answers_on_user_id"
  end

  create_table "quiz_questions", force: :cascade do |t|
    t.text "choices"
    t.datetime "created_at", null: false
    t.integer "points", null: false
    t.text "question", null: false
    t.string "question_type"
    t.integer "quiz_id", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_quiz_questions_on_quiz_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.boolean "closed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "due_at", null: false
    t.boolean "locked", default: false, null: false
    t.integer "subject_id", null: false
    t.string "title", null: false
    t.integer "total_points", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_quizzes_on_subject_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "day", null: false
    t.time "end_time", null: false
    t.string "room", null: false
    t.time "start_time", null: false
    t.integer "subject_id", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_schedules_on_subject_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.integer "department_id", null: false
    t.string "name", null: false
    t.integer "teacher_id", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_subjects_on_code", unique: true
    t.index ["department_id"], name: "index_subjects_on_department_id"
    t.index ["teacher_id"], name: "index_subjects_on_teacher_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "full_name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "assignment_submissions", "assignments"
  add_foreign_key "assignment_submissions", "users"
  add_foreign_key "assignments", "subjects"
  add_foreign_key "attendances", "subjects"
  add_foreign_key "attendances", "users"
  add_foreign_key "attendances", "users", column: "recorded_by_id"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "chat_participants", "chat_rooms"
  add_foreign_key "chat_participants", "users"
  add_foreign_key "chat_rooms", "subjects"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "departments", "colleges"
  add_foreign_key "enrollments", "subjects"
  add_foreign_key "enrollments", "users"
  add_foreign_key "materials", "subjects"
  add_foreign_key "messages", "chat_rooms"
  add_foreign_key "messages", "users"
  add_foreign_key "posts", "users", column: "author_id"
  add_foreign_key "quiz_answers", "quiz_questions"
  add_foreign_key "quiz_answers", "users"
  add_foreign_key "quiz_questions", "quizzes"
  add_foreign_key "quizzes", "subjects"
  add_foreign_key "schedules", "subjects"
  add_foreign_key "sessions", "users"
  add_foreign_key "subjects", "departments"
  add_foreign_key "subjects", "users", column: "teacher_id"
end
