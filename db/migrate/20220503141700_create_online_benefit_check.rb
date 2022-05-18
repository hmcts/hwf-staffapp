class CreateOnlineBenefitCheck < ActiveRecord::Migration[6.0]
  def change
    create_table :online_benefit_checks do |t|
      t.integer :online_application_id, index: true
      t.integer :user_id
      t.string :last_name
      t.date :date_of_birth
      t.string :ni_number
      t.date :date_to_check
      t.string :parameter_hash
      t.boolean :benefits_valid
      t.string :dwp_result
      t.string :error_message
      t.string :dwp_api_token
      t.string :our_api_token

      t.timestamps
    end
  end
end


