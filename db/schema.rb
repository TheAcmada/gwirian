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

ActiveRecord::Schema[8.0].define(version: 2025_11_11_085259) do
  create_table "features", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.text "background"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_id", null: false
    t.index ["project_id"], name: "index_features_on_project_id"
  end

  create_table "login_histories", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.text "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["email"], name: "index_project_members_on_email"
    t.index ["invitation_token"], name: "index_project_members_on_invitation_token", unique: true
    t.index ["project_id", "email"], name: "index_project_members_on_project_id_and_email", unique: true
    t.index ["project_id"], name: "index_project_members_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "features", "projects"
  add_foreign_key "login_histories", "users"
  add_foreign_key "project_members", "projects"
  add_foreign_key "sessions", "users"
end
