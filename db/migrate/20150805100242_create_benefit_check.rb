class CreateBenefitCheck < ActiveRecord::Migration
  def change
    create_table :benefit_checks do |t|
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
      t.references :application, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
    end
  end
end
