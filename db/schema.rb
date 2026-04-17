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

ActiveRecord::Schema[8.0].define(version: 2026_04_17_024627) do
  create_table "box_scores", force: :cascade do |t|
    t.string "task_name", null: false
    t.string "task_uuid", null: false
    t.string "uuid", null: false
    t.decimal "population", precision: 20, scale: 4, null: false
    t.datetime "time_stamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_uuid"], name: "index_box_scores_on_task_uuid"
    t.index ["time_stamp"], name: "index_box_scores_on_time_stamp"
    t.index ["uuid"], name: "index_box_scores_on_uuid", unique: true
  end

  create_table "import_logs", force: :cascade do |t|
    t.string "source_file", null: false
    t.string "import_type", null: false
    t.datetime "run_at", null: false
    t.integer "records_processed", default: 0, null: false
    t.integer "records_inserted", default: 0, null: false
    t.integer "records_skipped", default: 0, null: false
    t.text "error_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["import_type"], name: "index_import_logs_on_import_type"
    t.index ["run_at"], name: "index_import_logs_on_run_at"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "touched_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "name", null: false
    t.string "uuid", null: false
    t.string "host", null: false
    t.datetime "start_time", null: false
    t.datetime "stop_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tasks_on_name"
    t.index ["start_time"], name: "index_tasks_on_start_time"
    t.index ["uuid"], name: "index_tasks_on_uuid", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "sessions", "users"
end
