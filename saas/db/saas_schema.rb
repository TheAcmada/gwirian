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

ActiveRecord::Schema[8.0].define(version: 2026_03_07_120000) do
  create_table "paddle_webhook_events", force: :cascade do |t|
    t.string "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "event_type"
    t.json "payload", default: {}, null: false
    t.string "status", default: "received", null: false
    t.datetime "processed_at"
    t.datetime "failed_at"
    t.integer "attempts", default: 0, null: false
    t.text "error_message"
    t.index ["event_id"], name: "index_paddle_webhook_events_on_event_id", unique: true
    t.index ["status"], name: "index_paddle_webhook_events_on_status"
  end

  create_table "workspace_subscriptions", force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.string "plan_key", default: "free", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "paddle_subscription_id"
    t.string "paddle_customer_id"
    t.string "paddle_transaction_id"
    t.string "status", default: "active", null: false
    t.string "paddle_plan_price_id"
    t.datetime "current_period_starts_at"
    t.datetime "current_period_ends_at"
    t.datetime "canceled_at"
    t.datetime "paused_at"
    t.string "pending_action"
    t.string "pending_plan_key"
    t.string "sync_status", default: "synced", null: false
    t.datetime "last_synced_at"
    t.datetime "last_reconciled_at"
    t.string "last_paddle_event_id"
    t.text "sync_error"
    t.string "scheduled_change_action"
    t.datetime "scheduled_change_effective_at"
    t.index ["last_paddle_event_id"], name: "index_workspace_subscriptions_on_last_paddle_event_id"
    t.index ["paddle_subscription_id"], name: "index_workspace_subscriptions_on_paddle_subscription_id", unique: true, where: "paddle_subscription_id IS NOT NULL"
    t.index ["sync_status"], name: "index_workspace_subscriptions_on_sync_status"
    t.index ["workspace_id"], name: "index_workspace_subscriptions_on_workspace_id", unique: true
  end
end
