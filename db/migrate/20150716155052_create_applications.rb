class CreateApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :applications do |t|
      t.string  :title
      t.string  :first_name
      t.string  :last_name
      t.date    :date_of_birth
      t.string  :ni_number
      t.boolean :married
      t.decimal :fee
      t.string  :status
      t.timestamps null: false
      t.integer :jurisdiction_id
      t.date    :date_received
      t.string  :form_name
      t.string  :case_number
      t.boolean :probate
      t.string  :deceased_name
      t.date    :date_of_death
      t.boolean :refund
      t.date    :date_fee_paid
      t.references :user, index: true
      t.references :office, index: true

      t.timestamps null: false
    end
    add_foreign_key :applications, :users
    add_foreign_key :applications, :offices
  end
end
