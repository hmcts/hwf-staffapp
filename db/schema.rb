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

ActiveRecord::Schema.define(version: 20160322151510) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applicants", force: :cascade do |t|
    t.integer  "application_id", null: false
    t.string   "title"
    t.string   "first_name"
    t.string   "last_name"
    t.date     "date_of_birth"
    t.string   "ni_number"
    t.boolean  "married"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "applicants", ["application_id"], name: "index_applicants_on_application_id", using: :btree

  create_table "applications", force: :cascade do |t|
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "user_id"
    t.integer  "office_id"
    t.decimal  "threshold"
    t.boolean  "threshold_exceeded"
    t.boolean  "partner_over_61"
    t.boolean  "benefits"
    t.integer  "children"
    t.integer  "income"
    t.boolean  "dependents"
    t.string   "application_type"
    t.string   "outcome"
    t.integer  "amount_to_pay"
    t.boolean  "high_threshold_exceeded"
    t.string   "reference"
    t.datetime "completed_at"
    t.integer  "completed_by_id"
    t.string   "decision"
    t.string   "decision_type"
    t.integer  "state",                   default: 0, null: false
    t.string   "deleted_reason"
    t.datetime "deleted_at"
    t.integer  "deleted_by_id"
    t.integer  "business_entity_id"
    t.datetime "decision_date"
    t.decimal  "decision_cost"
  end

  add_index "applications", ["business_entity_id"], name: "index_applications_on_business_entity_id", using: :btree
  add_index "applications", ["office_id"], name: "index_applications_on_office_id", using: :btree
  add_index "applications", ["reference"], name: "index_applications_on_reference", unique: true, using: :btree
  add_index "applications", ["user_id"], name: "index_applications_on_user_id", using: :btree

  create_table "benefit_checks", force: :cascade do |t|
    t.string   "last_name"
    t.date     "date_of_birth"
    t.string   "ni_number"
    t.date     "date_to_check"
    t.string   "parameter_hash"
    t.boolean  "benefits_valid"
    t.string   "dwp_result"
    t.string   "error_message"
    t.string   "dwp_api_token"
    t.string   "our_api_token"
    t.integer  "application_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "benefit_checks", ["application_id"], name: "index_benefit_checks_on_application_id", using: :btree
  add_index "benefit_checks", ["user_id"], name: "index_benefit_checks_on_user_id", using: :btree

  create_table "benefit_overrides", force: :cascade do |t|
    t.integer  "application_id",  null: false
    t.boolean  "correct"
    t.integer  "completed_by_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "incorrect_reason"
  end

  add_index "benefit_overrides", ["application_id"], name: "index_benefit_overrides_on_application_id", using: :btree

  create_table "business_entities", force: :cascade do |t|
    t.integer  "office_id",       null: false
    t.integer  "jurisdiction_id", null: false
    t.string   "code",            null: false
    t.string   "name",            null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.datetime "valid_from"
    t.datetime "valid_to"
  end

  add_index "business_entities", ["code"], name: "index_business_entities_on_code", using: :btree
  add_index "business_entities", ["jurisdiction_id"], name: "index_business_entities_on_jurisdiction_id", using: :btree
  add_index "business_entities", ["name"], name: "index_business_entities_on_name", using: :btree
  add_index "business_entities", ["office_id", "jurisdiction_id", "valid_to"], name: "unique_active_office_jurisdiction", unique: true, using: :btree
  add_index "business_entities", ["office_id"], name: "index_business_entities_on_office_id", using: :btree

  create_table "details", force: :cascade do |t|
    t.integer  "application_id",   null: false
    t.decimal  "fee"
    t.integer  "jurisdiction_id"
    t.date     "date_received"
    t.string   "form_name"
    t.string   "case_number"
    t.boolean  "probate"
    t.string   "deceased_name"
    t.date     "date_of_death"
    t.boolean  "refund"
    t.date     "date_fee_paid"
    t.string   "emergency_reason"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "details", ["application_id"], name: "index_details_on_application_id", using: :btree

  create_table "evidence_checks", force: :cascade do |t|
    t.integer  "application_id",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expires_at",       null: false
    t.boolean  "correct"
    t.integer  "income"
    t.string   "outcome"
    t.integer  "amount_to_pay"
    t.datetime "completed_at"
    t.integer  "completed_by_id"
    t.string   "incorrect_reason"
  end

  add_index "evidence_checks", ["application_id"], name: "index_evidence_checks_on_application_id", using: :btree

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

  create_table "jurisdictions", force: :cascade do |t|
    t.string   "name"
    t.string   "abbr"
    t.boolean  "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "office_jurisdictions", id: false, force: :cascade do |t|
    t.integer "office_id",       null: false
    t.integer "jurisdiction_id", null: false
  end

  add_index "office_jurisdictions", ["office_id", "jurisdiction_id"], name: "index_office_jurisdictions_on_office_id_and_jurisdiction_id", using: :btree

  create_table "offices", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "entity_code"
  end

  create_table "online_applications", force: :cascade do |t|
    t.boolean  "married",            null: false
    t.boolean  "threshold_exceeded", null: false
    t.boolean  "benefits",           null: false
    t.integer  "children",           null: false
    t.integer  "income"
    t.boolean  "refund",             null: false
    t.date     "date_fee_paid"
    t.boolean  "probate",            null: false
    t.string   "deceased_name"
    t.date     "date_of_death"
    t.string   "case_number"
    t.string   "form_name"
    t.string   "ni_number",          null: false
    t.date     "date_of_birth",      null: false
    t.string   "title"
    t.string   "first_name",         null: false
    t.string   "last_name",          null: false
    t.text     "address",            null: false
    t.string   "postcode",           null: false
    t.boolean  "email_contact",      null: false
    t.string   "email_address"
    t.boolean  "phone_contact",      null: false
    t.string   "phone"
    t.boolean  "post_contact",       null: false
    t.string   "reference"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.decimal  "fee"
    t.integer  "jurisdiction_id"
    t.text     "emergency_reason"
    t.boolean  "feedback_opt_in",    null: false
  end

  add_index "online_applications", ["jurisdiction_id"], name: "index_online_applications_on_jurisdiction_id", using: :btree
  add_index "online_applications", ["reference"], name: "index_online_applications_on_reference", unique: true, using: :btree

  create_table "online_failures", force: :cascade do |t|
    t.text     "received_data", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "part_payments", force: :cascade do |t|
    t.integer  "application_id",   null: false
    t.datetime "expires_at",       null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.boolean  "correct"
    t.string   "incorrect_reason"
    t.datetime "completed_at"
    t.integer  "completed_by_id"
    t.string   "outcome"
  end

  add_index "part_payments", ["application_id"], name: "index_part_payments_on_application_id", using: :btree

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
    t.string   "role",                                null: false
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
    t.integer  "jurisdiction_id"
    t.datetime "deleted_at"
  end

  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "applications", "business_entities"
  add_foreign_key "applications", "offices"
  add_foreign_key "applications", "users"
  add_foreign_key "benefit_checks", "applications"
  add_foreign_key "benefit_checks", "users"
  add_foreign_key "benefit_overrides", "applications"
  add_foreign_key "feedbacks", "offices"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "office_jurisdictions", "jurisdictions"
  add_foreign_key "office_jurisdictions", "offices"
  add_foreign_key "online_applications", "jurisdictions", on_update: :cascade
  add_foreign_key "users", "jurisdictions"
  add_foreign_key "users", "offices"
end
