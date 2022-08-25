class CreateAuditPersonalDataPurge < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_personal_data_purges do |t|
      t.date :purged_date
      t.string :application_reference_number

      t.timestamps
    end
  end
end
