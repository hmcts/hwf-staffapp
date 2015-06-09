# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150609104815) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dwp_checks", force: :cascade do |t|
    t.string   "last_name"
    t.date     "dob"
    t.string   "ni_number"
    t.date     "date_to_check"
    t.boolean  "benefits_valid"
    t.string   "checked_by"
    t.string   "laa_code"
    t.string   "unique_number"
    t.integer  "created_by_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "dwp_result"
    t.string   "dwp_id"
    t.string   "our_api_token"
    t.integer  "office_id"
  end

  add_index "dwp_checks", ["created_by_id"], name: "index_dwp_checks_on_created_by_id", using: :btree
  add_index "dwp_checks", ["office_id"], name: "index_dwp_checks_on_office_id", using: :btree

  create_table "feedbacks", force: :cascade do |t|
    t.string   "experience"
    t.string   "ideas"
    t.integer  "rating"
    t.string   "help"
    t.integer  "user_id"
    t.integer  "office_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "feedbacks", ["office_id"], name: "index_feedbacks_on_office_id", using: :btree
  add_index "feedbacks", ["user_id"], name: "index_feedbacks_on_user_id", using: :btree

  create_table "offices", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "r2_calculators", force: :cascade do |t|
    t.decimal  "fee"
    t.boolean  "married"
    t.integer  "children"
    t.decimal  "income"
    t.decimal  "remittance"
    t.decimal  "to_pay"
    t.string   "type"
    t.integer  "created_by_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "r2_calculators", ["created_by_id"], name: "index_r2_calculators_on_created_by_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
    t.string   "name"
    t.integer  "office_id",                           null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "feedbacks", "offices"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "r2_calculators", "users", column: "created_by_id"
end
