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

ActiveRecord::Schema[8.1].define(version: 2025_12_09_033958) do
  create_table "event_recipient_budgets", force: :cascade do |t|
    t.decimal "budget", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.integer "event_recipient_id", null: false
    t.decimal "spent", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["event_recipient_id"], name: "index_event_recipient_budgets_on_event_recipient_id"
  end

  create_table "event_recipients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "event_id", null: false
    t.integer "recipient_id", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "recipient_id"], name: "index_event_recipients_on_event_id_and_recipient_id", unique: true
    t.index ["event_id"], name: "index_event_recipients_on_event_id"
    t.index ["recipient_id"], name: "index_event_recipients_on_recipient_id"
  end

  create_table "events", force: :cascade do |t|
    t.decimal "budget", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.date "event_date", null: false
    t.time "event_time"
    t.text "extra_info"
    t.string "location"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "event_date"], name: "index_events_on_user_id_and_event_date"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "gift_lists", force: :cascade do |t|
    t.boolean "archived", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "event_id"
    t.string "name"
    t.integer "recipient_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_gift_lists_on_event_id"
    t.index ["recipient_id"], name: "index_gift_lists_on_recipient_id"
  end

  create_table "gift_offers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.integer "gift_id", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.decimal "rating", precision: 3, scale: 2
    t.string "store_name", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["gift_id", "store_name"], name: "index_gift_offers_on_gift_id_and_store_name"
    t.index ["gift_id"], name: "index_gift_offers_on_gift_id"
  end

  create_table "gifts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "gift_list_id"
    t.string "name"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["gift_list_id"], name: "index_gifts_on_gift_list_id"
    t.index ["status"], name: "index_gifts_on_status"
  end

  create_table "recipients", force: :cascade do |t|
    t.integer "age"
    t.date "birthday"
    t.datetime "created_at", null: false
    t.text "dislikes"
    t.text "extra_info"
    t.integer "gender"
    t.text "hobbies"
    t.text "likes"
    t.integer "max_age"
    t.integer "min_age"
    t.string "name"
    t.string "occupation"
    t.string "relation"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_recipients_on_user_id"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.integer "byte_size", limit: 4, null: false
    t.datetime "created_at", null: false
    t.binary "key", limit: 1024, null: false
    t.integer "key_hash", limit: 8, null: false
    t.binary "value", limit: 536870912, null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name"
    t.string "password_digest"
    t.string "session_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["session_token"], name: "index_users_on_session_token", unique: true
  end

  add_foreign_key "event_recipient_budgets", "event_recipients"
  add_foreign_key "event_recipients", "events"
  add_foreign_key "event_recipients", "recipients"
  add_foreign_key "events", "users"
  add_foreign_key "gift_lists", "events"
  add_foreign_key "gift_lists", "recipients"
  add_foreign_key "gift_offers", "gifts"
  add_foreign_key "gifts", "gift_lists"
  add_foreign_key "recipients", "users"
end
