class CreateApplications < ActiveRecord::Migration
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
    end
  end
end
