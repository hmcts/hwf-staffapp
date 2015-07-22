class AddPage2FieldsToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :jurisdiction_id, :integer
    add_column :applications, :date_received, :date
    add_column :applications, :form_name, :string
    add_column :applications, :case_number, :string
    add_column :applications, :probate, :boolean
    add_column :applications, :deceased_name, :string
    add_column :applications, :date_of_death, :date
    add_column :applications, :refund, :boolean
    add_column :applications, :date_fee_paid, :date

    add_foreign_key :applications, :jurisdictions
  end
end
