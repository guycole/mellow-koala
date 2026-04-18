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

ActiveRecord::Schema[8.0].define(version: 2026_04_18_072055) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "collection_snapshots", force: :cascade do |t|
    t.bigint "component_id", null: false
    t.string "snapshot_id", null: false
    t.datetime "captured_at"
    t.datetime "received_at", null: false
    t.string "status", null: false
    t.jsonb "payload", null: false
    t.jsonb "error_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id", "received_at"], name: "index_collection_snapshots_on_component_id_and_received_at"
    t.index ["component_id", "snapshot_id"], name: "idx_collection_snapshots_component_snapshot", unique: true
    t.index ["component_id"], name: "index_collection_snapshots_on_component_id"
  end

  create_table "components", force: :cascade do |t|
    t.string "component_id", null: false
    t.string "display_name", null: false
    t.string "slug", null: false
    t.text "description"
    t.string "ingest_token_digest", null: false
    t.datetime "token_rotated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_components_on_component_id", unique: true
    t.index ["slug"], name: "index_components_on_slug", unique: true
  end

  create_table "configuration_snapshots", force: :cascade do |t|
    t.bigint "component_id", null: false
    t.string "snapshot_id", null: false
    t.datetime "captured_at"
    t.datetime "received_at", null: false
    t.string "status", null: false
    t.jsonb "payload", null: false
    t.jsonb "error_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id", "received_at"], name: "index_configuration_snapshots_on_component_id_and_received_at"
    t.index ["component_id", "snapshot_id"], name: "idx_config_snapshots_component_snapshot", unique: true
    t.index ["component_id"], name: "index_configuration_snapshots_on_component_id"
  end

  add_foreign_key "collection_snapshots", "components"
  add_foreign_key "configuration_snapshots", "components"
end
