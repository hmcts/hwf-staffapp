class AddHmrcChecksTable < ActiveRecord::Migration[6.0]
  def change
    create_table :hmrc_checks do |t|
      t.integer :application_id, null: false
      t.integer :user_id
      t.string :ni_number
      t.string :date_of_birth
      t.text :address
      t.text :employment
      t.text :income
      t.text :tax_credit
      t.string :error_response
      t.string :request_params

      t.timestamps
    end
  end
end
