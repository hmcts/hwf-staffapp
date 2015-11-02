class DropDwpChecks < ActiveRecord::Migration
  def change
    drop_table :dwp_checks do |t|
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
      t.references :created_by, references: :users, index: true
      t.timestamps null: false
    end
  end
end
