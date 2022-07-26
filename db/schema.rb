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

ActiveRecord::Schema.define(version: 2022_07_19_132228) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abstract_web_objects", force: :cascade do |t|
    t.string "object_name", null: false
    t.string "object_key", null: false
    t.string "description"
    t.string "region", null: false
    t.string "position", null: false
    t.string "url", null: false
    t.string "api_key", null: false
    t.integer "user_id"
    t.integer "actable_id"
    t.string "actable_type"
    t.datetime "pinged_at"
    t.integer "major_version"
    t.integer "minor_version"
    t.integer "patch_version"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "server_id"
    t.integer "transactions_count", default: 0
    t.string "hover_text_color", default: "#ff0000"
    t.index ["description"], name: "index_abstract_web_objects_on_description"
    t.index ["object_key"], name: "index_abstract_web_objects_on_object_key"
    t.index ["object_name"], name: "index_abstract_web_objects_on_object_name"
    t.index ["region"], name: "index_abstract_web_objects_on_region"
    t.index ["user_id"], name: "index_abstract_web_objects_on_user_id"
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "analyzable_detections", force: :cascade do |t|
    t.integer "visit_id"
    t.string "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "analyzable_employees", force: :cascade do |t|
    t.string "avatar_name"
    t.string "avatar_key"
    t.integer "hourly_pay"
    t.integer "max_hours"
    t.integer "pay_owed", default: 0
    t.float "hours_worked", default: 0.0
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "analyzable_inventories", force: :cascade do |t|
    t.string "inventory_name"
    t.string "inventory_description"
    t.integer "price"
    t.integer "user_id"
    t.integer "server_id"
    t.integer "inventory_type"
    t.integer "owner_perms"
    t.integer "next_perms"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "transactions_count", default: 0
    t.integer "revenue", default: 0
  end

  create_table "analyzable_parcels", force: :cascade do |t|
    t.string "parcel_name"
    t.string "description"
    t.string "renter_key"
    t.string "renter_name"
    t.integer "area"
    t.integer "max_prims"
    t.string "rating"
    t.string "parcel_key"
    t.integer "weekly_rent"
    t.integer "purchase_price"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "region"
    t.integer "user_id"
    t.datetime "expiration_date"
    t.string "position"
    t.string "current_state"
    t.string "image_key"
  end

  create_table "analyzable_product_links", force: :cascade do |t|
    t.integer "product_id"
    t.string "link_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id"
  end

  create_table "analyzable_products", force: :cascade do |t|
    t.integer "user_id"
    t.string "image_key"
    t.string "product_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "product_links_count"
    t.integer "transactions_count", default: 0
    t.integer "revenue", default: 0
  end

  create_table "analyzable_rental_states", force: :cascade do |t|
    t.datetime "closed_at"
    t.integer "state"
    t.integer "rentable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id"
    t.string "rentable_type"
  end

  create_table "analyzable_sessions", force: :cascade do |t|
    t.string "avatar_name"
    t.string "avatar_key"
    t.datetime "stopped_at"
    t.integer "duration"
    t.integer "sessionable_id"
    t.string "sessionable_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id"
  end

  create_table "analyzable_transactions", force: :cascade do |t|
    t.text "description"
    t.integer "amount"
    t.integer "balance"
    t.integer "user_id"
    t.integer "transaction_id"
    t.string "source_key"
    t.string "source_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "source_type"
    t.string "transaction_key"
    t.integer "category", default: 0, null: false
    t.integer "previous_balance"
    t.string "target_name"
    t.string "target_key"
    t.integer "transactable_id"
    t.string "transactable_type"
    t.integer "session_id"
    t.integer "inventory_id"
    t.integer "product_id"
    t.integer "parcel_id"
    t.index ["amount"], name: "index_analyzable_transactions_on_amount"
    t.index ["category"], name: "index_analyzable_transactions_on_category"
    t.index ["description"], name: "index_analyzable_transactions_on_description"
    t.index ["source_key"], name: "index_analyzable_transactions_on_source_key"
    t.index ["source_name"], name: "index_analyzable_transactions_on_source_name"
    t.index ["source_type"], name: "index_analyzable_transactions_on_source_type"
    t.index ["target_key"], name: "index_analyzable_transactions_on_target_key"
    t.index ["target_name"], name: "index_analyzable_transactions_on_target_name"
    t.index ["transaction_key"], name: "index_analyzable_transactions_on_transaction_key"
    t.index ["user_id"], name: "index_analyzable_transactions_on_user_id"
  end

  create_table "analyzable_visits", force: :cascade do |t|
    t.integer "web_object_id"
    t.string "avatar_key"
    t.string "avatar_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "start_time"
    t.datetime "stop_time"
    t.integer "duration"
    t.integer "user_id"
    t.string "region"
  end

  create_table "analyzable_work_sessions", force: :cascade do |t|
    t.integer "employee_id"
    t.float "duration"
    t.datetime "stopped_at"
    t.integer "pay"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "avatars", force: :cascade do |t|
    t.string "avatar_key"
    t.string "avatar_name"
    t.string "display_name"
    t.date "rezday"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["avatar_key"], name: "index_avatars_on_avatar_key"
    t.index ["avatar_name"], name: "index_avatars_on_avatar_name"
    t.index ["display_name"], name: "index_avatars_on_display_name"
  end

  create_table "comments", force: :cascade do |t|
    t.text "text"
    t.string "author"
    t.integer "service_ticket_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "listable_avatars", force: :cascade do |t|
    t.string "avatar_name"
    t.string "avatar_key"
    t.string "list_name"
    t.integer "listable_id"
    t.string "listable_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "rezzable_donation_boxes", force: :cascade do |t|
    t.boolean "show_last_donation", default: false
    t.boolean "show_last_donor", default: false
    t.boolean "show_total", default: true
    t.boolean "show_largest_donation", default: false
    t.boolean "show_biggest_donor", default: false
    t.integer "total", default: 0
    t.integer "goal"
    t.datetime "dead_line"
    t.string "response", default: "Thank you!"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "default_price", default: -1
    t.integer "quick_pay_1", default: -2
    t.integer "quick_pay_2", default: -2
    t.integer "quick_pay_3", default: -2
    t.integer "quick_pay_4", default: -2
  end

  create_table "rezzable_parcel_boxes", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "parcel_id"
  end

  create_table "rezzable_servers", force: :cascade do |t|
  end

  create_table "rezzable_service_boards", force: :cascade do |t|
    t.integer "weekly_rent"
    t.datetime "expiration_date"
    t.string "renter_name"
    t.string "renter_key"
    t.string "current_state", default: "for_rent"
    t.string "image_name"
    t.string "image_key"
    t.string "notecard_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "rezzable_shop_rental_boxes", force: :cascade do |t|
    t.integer "weekly_rent"
    t.integer "allowed_land_impact"
    t.integer "current_land_impact"
    t.datetime "expiration_date"
    t.string "renter_name"
    t.string "renter_key"
    t.string "current_state", default: "open"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "rezzable_terminals", force: :cascade do |t|
  end

  create_table "rezzable_tier_stations", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "rezzable_time_cops", force: :cascade do |t|
    t.boolean "autopay", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "rezzable_tip_jars", force: :cascade do |t|
    t.integer "split_percent", default: 100
    t.integer "access_mode", default: 0
    t.string "logged_in_key"
    t.string "logged_in_name"
    t.string "thank_you_message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "show_last_tip", default: true
    t.boolean "show_last_tipper", default: true
    t.boolean "show_total", default: true
    t.integer "sensor_mode", default: 0
    t.integer "inactive_time", default: 60
    t.boolean "show_duration", default: false
    t.boolean "show_hover_text", default: true
  end

  create_table "rezzable_traffic_cops", force: :cascade do |t|
    t.boolean "power"
    t.integer "sensor_mode", default: 0
    t.integer "security_mode", default: 0
    t.string "first_visit_message"
    t.string "repeat_visit_message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "access_mode", default: 0
    t.string "inventory_to_give"
  end

  create_table "rezzable_vendors", force: :cascade do |t|
    t.string "inventory_name"
    t.string "image_key"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "revenue", default: 0
  end

  create_table "rezzable_web_objects", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "service_tickets", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "client_key"
    t.integer "user_id"
    t.integer "status", default: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "client_name"
  end

  create_table "splits", force: :cascade do |t|
    t.integer "percent"
    t.integer "splittable_id"
    t.string "splittable_type"
    t.string "target_name"
    t.string "target_key"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["percent"], name: "index_splits_on_percent"
    t.index ["target_key"], name: "index_splits_on_target_key"
    t.index ["target_name"], name: "index_splits_on_target_name"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_name", default: "", null: false
    t.string "avatar_key", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "role", default: 0
    t.integer "account_level", default: 0
    t.datetime "expiration_date"
    t.integer "web_objects_count", default: 0
    t.integer "web_objects_weight", default: 0
    t.string "image_key"
    t.string "business_name"
    t.string "default_image_key"
    t.string "visit_us_slurl"
    t.index ["account_level"], name: "index_users_on_account_level"
    t.index ["avatar_key"], name: "index_users_on_avatar_key", unique: true
    t.index ["avatar_name"], name: "index_users_on_avatar_name", unique: true
    t.index ["expiration_date"], name: "index_users_on_expiration_date"
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
