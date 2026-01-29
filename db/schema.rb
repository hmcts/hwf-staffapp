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

ActiveRecord::Schema[8.1].define(version: 2026_01_02_140022) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "tablefunc"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
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

  create_table "ahoy_events", force: :cascade do |t|
    t.integer "application_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.bigint "user_id"
    t.bigint "visit_id"
    t.index ["application_id"], name: "index_ahoy_events_on_application_id"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "app_version"
    t.string "browser"
    t.string "city"
    t.string "country"
    t.string "device_type"
    t.string "ip"
    t.text "landing_page"
    t.float "latitude"
    t.float "longitude"
    t.string "os"
    t.string "os_version"
    t.string "platform"
    t.text "referrer"
    t.string "referring_domain"
    t.string "region"
    t.datetime "started_at"
    t.text "user_agent"
    t.bigint "user_id"
    t.string "utm_campaign"
    t.string "utm_content"
    t.string "utm_medium"
    t.string "utm_source"
    t.string "utm_term"
    t.string "visit_token"
    t.string "visitor_token"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
    t.index ["visitor_token", "started_at"], name: "index_ahoy_visits_on_visitor_token_and_started_at"
  end

  create_table "applicants", id: :serial, force: :cascade do |t|
    t.integer "application_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.date "date_of_birth"
    t.string "first_name"
    t.string "ho_number"
    t.string "last_name"
    t.boolean "married"
    t.string "ni_number"
    t.boolean "over_16"
    t.date "partner_date_of_birth"
    t.string "partner_first_name"
    t.string "partner_last_name"
    t.string "partner_ni_number"
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
    t.index "lower((((first_name)::text || ' '::text) || (last_name)::text))", name: "index_applicants_on_full_name_lower"
    t.index ["application_id"], name: "index_applicants_on_application_id"
    t.index ["first_name"], name: "index_applicants_on_first_name"
    t.index ["first_name"], name: "index_applicants_on_first_name_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["last_name"], name: "index_applicants_on_last_name"
    t.index ["last_name"], name: "index_applicants_on_last_name_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["ni_number"], name: "index_applicants_on_ni_number"
    t.index ["ni_number"], name: "index_applicants_on_ni_number_trgm", opclass: :gin_trgm_ops, using: :gin
  end

  create_table "applications", id: :serial, force: :cascade do |t|
    t.bigint "ahoy_visit_id"
    t.decimal "amount_to_pay", default: "0.0"
    t.string "application_type"
    t.boolean "benefits"
    t.integer "business_entity_id"
    t.integer "children"
    t.text "children_age_band"
    t.datetime "completed_at", precision: nil
    t.integer "completed_by_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "decision"
    t.decimal "decision_cost"
    t.datetime "decision_date", precision: nil
    t.string "decision_type"
    t.datetime "deleted_at", precision: nil
    t.integer "deleted_by_id"
    t.string "deleted_reason"
    t.string "deleted_reasons_list"
    t.boolean "dependents"
    t.integer "income"
    t.string "income_kind"
    t.decimal "income_max_threshold"
    t.boolean "income_max_threshold_exceeded"
    t.decimal "income_min_threshold"
    t.boolean "income_min_threshold_exceeded"
    t.string "income_period"
    t.string "medium"
    t.integer "office_id"
    t.integer "online_application_id"
    t.string "outcome"
    t.boolean "partner_over_66"
    t.boolean "purged", default: false
    t.date "purged_at"
    t.string "reference"
    t.integer "state", default: 0, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["ahoy_visit_id"], name: "index_applications_on_ahoy_visit_id"
    t.index ["business_entity_id"], name: "index_applications_on_business_entity_id"
    t.index ["created_at"], name: "index_applications_on_created_at"
    t.index ["decision_cost"], name: "index_applications_on_decision_cost"
    t.index ["decision_date"], name: "index_applications_on_decision_date"
    t.index ["office_id"], name: "index_applications_on_office_id"
    t.index ["online_application_id"], name: "index_applications_on_online_application_id"
    t.index ["purged", "state", "office_id"], name: "index_applications_on_purged_state_office", where: "((purged IS NULL) OR (purged = false))"
    t.index ["purged", "state"], name: "index_applications_on_purged_state", where: "(((purged IS NULL) OR (purged = false)) AND (state <> 0))"
    t.index ["reference"], name: "index_applications_on_reference", unique: true
    t.index ["state"], name: "index_applications_on_state"
    t.index ["user_id"], name: "index_applications_on_user_id"
  end

  create_table "audit_personal_data_purges", force: :cascade do |t|
    t.string "application_reference_number"
    t.datetime "created_at", null: false
    t.date "purged_date"
    t.datetime "updated_at", null: false
  end

  create_table "benefit_checks", id: :serial, force: :cascade do |t|
    t.string "api_response"
    t.integer "application_id"
    t.integer "applicationable_id"
    t.string "applicationable_type"
    t.boolean "benefits_valid"
    t.datetime "created_at", precision: nil
    t.date "date_of_birth"
    t.date "date_to_check"
    t.string "dwp_api_token"
    t.string "dwp_result"
    t.string "error_message"
    t.string "last_name"
    t.string "ni_number"
    t.string "our_api_token"
    t.string "parameter_hash"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["application_id"], name: "index_benefit_checks_on_application_id"
    t.index ["applicationable_id", "applicationable_type"], name: "index_bc_applicationable_id_type"
    t.index ["user_id"], name: "index_benefit_checks_on_user_id"
  end

  create_table "benefit_overrides", id: :serial, force: :cascade do |t|
    t.integer "application_id", null: false
    t.integer "completed_by_id"
    t.boolean "correct"
    t.datetime "created_at", precision: nil, null: false
    t.string "incorrect_reason"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["application_id"], name: "index_benefit_overrides_on_application_id"
  end

  create_table "business_entities", id: :serial, force: :cascade do |t|
    t.string "be_code"
    t.datetime "created_at", precision: nil, null: false
    t.integer "jurisdiction_id", null: false
    t.string "name", null: false
    t.integer "office_id", null: false
    t.string "sop_code"
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "valid_from", precision: nil
    t.datetime "valid_to", precision: nil
    t.index ["jurisdiction_id"], name: "index_business_entities_on_jurisdiction_id"
    t.index ["name"], name: "index_business_entities_on_name"
    t.index ["office_id", "jurisdiction_id", "valid_to"], name: "unique_active_office_jurisdiction", unique: true
    t.index ["office_id"], name: "index_business_entities_on_office_id"
  end

  create_table "decision_overrides", id: :serial, force: :cascade do |t|
    t.integer "application_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "reason"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["application_id"], name: "index_decision_overrides_on_application_id"
    t.index ["user_id"], name: "index_decision_overrides_on_user_id"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", precision: nil
    t.string "cron"
    t.datetime "failed_at", precision: nil
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "locked_at", precision: nil
    t.string "locked_by"
    t.integer "priority", default: 0, null: false
    t.string "queue"
    t.datetime "run_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "details", id: :serial, force: :cascade do |t|
    t.integer "application_id", null: false
    t.string "calculation_scheme"
    t.string "case_number"
    t.datetime "created_at", precision: nil, null: false
    t.date "date_fee_paid"
    t.date "date_of_death"
    t.date "date_received"
    t.string "deceased_name"
    t.boolean "discretion_applied"
    t.string "discretion_manager_name"
    t.string "discretion_reason"
    t.string "emergency_reason"
    t.decimal "fee"
    t.string "fee_manager_firstname"
    t.string "fee_manager_lastname"
    t.string "form_name"
    t.integer "jurisdiction_id"
    t.boolean "probate"
    t.boolean "refund"
    t.string "statement_signed_by"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["application_id"], name: "index_details_on_application_id"
    t.index ["case_number"], name: "index_details_on_case_number"
    t.index ["case_number"], name: "index_details_on_case_number_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["fee"], name: "index_details_on_fee"
  end

  create_table "dev_notes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "notable_id", null: false
    t.string "notable_type", null: false
    t.string "note"
    t.datetime "updated_at", null: false
    t.index ["notable_type", "notable_id"], name: "index_dev_notes_on_notable"
  end

  create_table "dwp_warnings", id: :serial, force: :cascade do |t|
    t.string "check_state", default: "default_checker"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "evidence_check_flags", id: :serial, force: :cascade do |t|
    t.boolean "active", default: true
    t.integer "count"
    t.datetime "created_at", precision: nil, null: false
    t.string "reg_number"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["reg_number", "active"], name: "evidence_check_flags_active_unique", unique: true, where: "(active = true)"
  end

  create_table "evidence_checks", id: :serial, force: :cascade do |t|
    t.decimal "amount_to_pay", default: "0.0"
    t.integer "application_id", null: false
    t.string "check_type"
    t.string "checks_annotation"
    t.datetime "completed_at", precision: nil
    t.integer "completed_by_id"
    t.boolean "correct"
    t.datetime "created_at", precision: nil
    t.datetime "expires_at", precision: nil, null: false
    t.decimal "hmrc_income_used", default: "0.0"
    t.integer "income"
    t.string "income_check_type"
    t.string "incorrect_reason"
    t.string "incorrect_reason_category"
    t.string "outcome"
    t.string "staff_error_details"
    t.datetime "updated_at", precision: nil
    t.index ["application_id"], name: "index_evidence_checks_on_application_id"
  end

  create_table "export_file_storages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "feature_switchings", force: :cascade do |t|
    t.datetime "activation_time"
    t.datetime "created_at", null: false
    t.boolean "enabled", default: false
    t.string "feature_key", null: false
    t.integer "office_id"
    t.datetime "updated_at", null: false
    t.index ["feature_key"], name: "index_feature_switchings_on_feature_key", unique: true
  end

  create_table "feedbacks", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "experience"
    t.string "help"
    t.string "ideas"
    t.integer "office_id"
    t.integer "rating"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["office_id"], name: "index_feedbacks_on_office_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "hmrc_calls", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "call_params"
    t.datetime "created_at", null: false
    t.string "endpoint_name"
    t.integer "hmrc_check_id", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hmrc_checks", force: :cascade do |t|
    t.integer "additional_income", default: 0
    t.text "address"
    t.string "check_type", default: "applicant"
    t.datetime "created_at", null: false
    t.string "date_of_birth"
    t.text "employment"
    t.string "error_response"
    t.integer "evidence_check_id", null: false
    t.text "income"
    t.string "ni_number"
    t.datetime "purged_at", precision: nil
    t.string "request_params"
    t.string "sa_income"
    t.text "tax_credit"
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "hmrc_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "encrypted_access_token"
    t.datetime "expires_in", precision: nil
    t.datetime "updated_at", null: false
  end

  create_table "jurisdictions", id: :serial, force: :cascade do |t|
    t.string "abbr"
    t.boolean "active"
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "message"
    t.boolean "show", default: false, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "office_jurisdictions", id: false, force: :cascade do |t|
    t.integer "jurisdiction_id", null: false
    t.integer "office_id", null: false
    t.index ["office_id", "jurisdiction_id"], name: "index_office_jurisdictions_on_office_id_and_jurisdiction_id"
  end

  create_table "offices", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "entity_code"
    t.string "name"
    t.datetime "updated_at", precision: nil
  end

  create_table "online_applications", id: :serial, force: :cascade do |t|
    t.text "address", null: false
    t.integer "amount"
    t.string "applying_method"
    t.string "applying_on_behalf"
    t.boolean "benefits", null: false
    t.boolean "benefits_override", default: false
    t.string "calculation_scheme"
    t.string "case_number"
    t.integer "children"
    t.string "children_age_band"
    t.datetime "created_at", precision: nil, null: false
    t.date "date_fee_paid"
    t.date "date_of_birth", null: false
    t.date "date_of_death"
    t.date "date_received"
    t.string "deceased_name"
    t.boolean "discretion_applied"
    t.boolean "dwp_manual_decision"
    t.string "email_address"
    t.boolean "email_contact", null: false
    t.text "emergency_reason"
    t.decimal "fee"
    t.string "fee_manager_firstname"
    t.string "fee_manager_lastname"
    t.boolean "feedback_opt_in", null: false
    t.string "first_name", null: false
    t.string "form_name"
    t.string "ho_number"
    t.integer "income"
    t.string "income_kind"
    t.boolean "income_max_threshold_exceeded"
    t.boolean "income_min_threshold_exceeded"
    t.string "income_period"
    t.integer "jurisdiction_id"
    t.string "last_name", null: false
    t.boolean "legal_representative"
    t.string "legal_representative_address"
    t.string "legal_representative_email"
    t.string "legal_representative_feedback_opt_in"
    t.string "legal_representative_first_name"
    t.string "legal_representative_last_name"
    t.string "legal_representative_organisation_name"
    t.string "legal_representative_position"
    t.string "legal_representative_postcode"
    t.string "legal_representative_street"
    t.string "legal_representative_town"
    t.boolean "married", null: false
    t.boolean "max_threshold_exceeded"
    t.boolean "min_threshold_exceeded", null: false
    t.string "ni_number"
    t.boolean "over_16"
    t.boolean "over_66"
    t.date "partner_date_of_birth"
    t.string "partner_first_name"
    t.string "partner_last_name"
    t.string "partner_ni_number"
    t.string "phone"
    t.boolean "phone_contact", null: false
    t.boolean "post_contact", null: false
    t.string "postcode", null: false
    t.boolean "probate"
    t.boolean "purged", default: false
    t.date "purged_at"
    t.string "reference"
    t.boolean "refund", null: false
    t.string "statement_signed_by"
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["jurisdiction_id"], name: "index_online_applications_on_jurisdiction_id"
    t.index ["reference"], name: "index_online_applications_on_reference", unique: true
  end

  create_table "online_failures", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "received_data", null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "part_payments", id: :serial, force: :cascade do |t|
    t.integer "application_id", null: false
    t.datetime "completed_at", precision: nil
    t.integer "completed_by_id"
    t.boolean "correct"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil, null: false
    t.string "incorrect_reason"
    t.string "outcome"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["application_id"], name: "index_part_payments_on_application_id"
  end

  create_table "representatives", force: :cascade do |t|
    t.integer "application_id", null: false
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "organisation"
    t.string "position"
    t.datetime "updated_at", null: false
  end

  create_table "savings", id: :serial, force: :cascade do |t|
    t.decimal "amount"
    t.integer "application_id", null: false
    t.string "choice"
    t.datetime "created_at", precision: nil, null: false
    t.decimal "fee_threshold"
    t.decimal "max_threshold"
    t.boolean "max_threshold_exceeded"
    t.decimal "min_threshold"
    t.boolean "min_threshold_exceeded"
    t.boolean "over_66"
    t.boolean "passed"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["application_id"], name: "index_savings_on_application_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.datetime "deleted_at", precision: nil
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: ""
    t.datetime "invitation_accepted_at", precision: nil
    t.datetime "invitation_created_at", precision: nil
    t.integer "invitation_limit"
    t.datetime "invitation_sent_at", precision: nil
    t.string "invitation_token"
    t.integer "invitations_count", default: 0
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.integer "jurisdiction_id"
    t.datetime "last_password_reset_check_at"
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.string "name"
    t.integer "office_id", null: false
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.string "role", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.string "unconfirmed_email"
    t.string "unique_session_id"
    t.datetime "updated_at", precision: nil
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "event", null: false
    t.integer "item_id", null: false
    t.string "item_type", null: false
    t.text "object"
    t.text "object_changes"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "applicants", "applications", on_update: :cascade
  add_foreign_key "applications", "business_entities", on_update: :cascade
  add_foreign_key "applications", "offices", on_update: :cascade
  add_foreign_key "applications", "online_applications", on_update: :cascade
  add_foreign_key "applications", "users", column: "completed_by_id", on_update: :cascade
  add_foreign_key "applications", "users", column: "deleted_by_id", on_update: :cascade
  add_foreign_key "applications", "users", on_update: :cascade
  add_foreign_key "benefit_checks", "applications", on_update: :cascade
  add_foreign_key "benefit_checks", "users", on_update: :cascade
  add_foreign_key "benefit_overrides", "applications", on_update: :cascade
  add_foreign_key "benefit_overrides", "users", column: "completed_by_id", on_update: :cascade
  add_foreign_key "business_entities", "jurisdictions", on_update: :cascade
  add_foreign_key "business_entities", "offices", on_update: :cascade
  add_foreign_key "decision_overrides", "applications"
  add_foreign_key "decision_overrides", "users"
  add_foreign_key "details", "applications", on_update: :cascade
  add_foreign_key "details", "jurisdictions", on_update: :cascade
  add_foreign_key "evidence_checks", "applications", on_update: :cascade
  add_foreign_key "evidence_checks", "users", column: "completed_by_id", on_update: :cascade
  add_foreign_key "feedbacks", "offices", on_update: :cascade
  add_foreign_key "feedbacks", "users", on_update: :cascade
  add_foreign_key "office_jurisdictions", "jurisdictions", on_update: :cascade
  add_foreign_key "office_jurisdictions", "offices", on_update: :cascade
  add_foreign_key "online_applications", "jurisdictions", on_update: :cascade
  add_foreign_key "part_payments", "applications", on_update: :cascade
  add_foreign_key "part_payments", "users", column: "completed_by_id", on_update: :cascade
  add_foreign_key "savings", "applications"
  add_foreign_key "users", "jurisdictions", on_update: :cascade
  add_foreign_key "users", "offices", on_update: :cascade
end
