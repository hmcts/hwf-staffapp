class AddOnlineApplicationTables < ActiveRecord::Migration[5.2]
  def change
    create_table :online_failures do |t|
      t.text :received_data, null: false
      t.timestamps null: false
    end

    create_table :online_applications do |t|
      t.boolean :married, null: false
      t.boolean :threshold_exceeded, null: false
      t.boolean :benefits, null: false
      t.integer :children, null: false
      t.integer :income

      t.boolean :refund, null: false
      t.date :date_fee_paid

      t.boolean :probate, null: false
      t.string :deceased_name
      t.date :date_of_death

      t.string :case_number
      t.string :form_name

      t.string :ni_number, null: false
      t.date :date_of_birth, null: false
      t.string :title
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.text :address, null: false
      t.string :postcode, null: false

      t.boolean :email_contact, null: false
      t.string :email_address
      t.boolean :phone_contact, null: false
      t.string :phone
      t.boolean :post_contact, null: false

      t.string :reference

      t.timestamps null: false
    end

    add_index :online_applications, :reference, unique: true


  end
end
