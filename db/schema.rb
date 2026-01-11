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

ActiveRecord::Schema[8.0].define(version: 2026_01_11_131233) do
  create_table "features", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_id", null: false
    t.text "background"
    t.index ["project_id"], name: "index_features_on_project_id"
  end

  create_table "login_histories", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.text "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_login_histories_on_created_at"
    t.index ["user_id"], name: "index_login_histories_on_user_id"
  end

  create_table "project_members", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "email", null: false
    t.string "role", default: "guest", null: false
    t.boolean "invitation_accepted", default: false, null: false
    t.string "project_members"
    t.string "invitation_token"
    t.datetime "last_invitation_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "invitation_token_expires_at"
    t.index ["email"], name: "index_project_members_on_email"
    t.index ["invitation_token"], name: "index_project_members_on_invitation_token", unique: true
    t.index ["invitation_token_expires_at"], name: "index_project_members_on_invitation_token_expires_at"
    t.index ["project_id", "email"], name: "index_project_members_on_project_id_and_email", unique: true
    t.index ["project_id"], name: "index_project_members_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "workspace_id", null: false
    t.index ["workspace_id"], name: "index_projects_on_workspace_id"
  end

  create_table "scenario_executions", force: :cascade do |t|
    t.integer "scenario_id", null: false
    t.integer "user_id", null: false
    t.string "status", default: "pending", null: false
    t.text "notes"
    t.datetime "executed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["scenario_id", "executed_at"], name: "index_scenario_executions_on_scenario_id_and_executed_at"
    t.index ["scenario_id"], name: "index_scenario_executions_on_scenario_id"
    t.index ["user_id"], name: "index_scenario_executions_on_user_id"
  end

  create_table "scenarios", force: :cascade do |t|
    t.integer "feature_id", null: false
    t.string "title"
    t.string "given"
    t.string "when"
    t.string "then"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.index ["feature_id"], name: "index_scenarios_on_feature_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expires_at"
    t.index ["created_at"], name: "index_sessions_on_created_at"
    t.index ["expires_at"], name: "index_sessions_on_expires_at"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "steps", force: :cascade do |t|
    t.integer "scenario_id", null: false
    t.text "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.index ["scenario_id"], name: "index_steps_on_scenario_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_token"
    t.datetime "api_token_expires_at"
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "workspace_members", force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.integer "user_id", null: false
    t.string "role", default: "viewer", null: false
    t.string "status", default: "invited", null: false
    t.datetime "last_invitation_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_workspace_members_on_status"
    t.index ["user_id"], name: "index_workspace_members_on_user_id"
    t.index ["workspace_id", "user_id"], name: "index_workspace_members_on_workspace_id_and_user_id", unique: true
    t.index ["workspace_id"], name: "index_workspace_members_on_workspace_id"
  end

  create_table "workspaces", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "features", "projects"
  add_foreign_key "login_histories", "users"
  add_foreign_key "project_members", "projects"
  add_foreign_key "projects", "workspaces"
  add_foreign_key "scenario_executions", "scenarios"
  add_foreign_key "scenario_executions", "users"
  add_foreign_key "scenarios", "features"
  add_foreign_key "sessions", "users"
  add_foreign_key "steps", "scenarios"
  add_foreign_key "taggings", "tags"
  add_foreign_key "workspace_members", "users"
  add_foreign_key "workspace_members", "workspaces"
end
