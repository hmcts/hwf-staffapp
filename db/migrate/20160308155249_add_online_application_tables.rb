class AddOnlineApplicationTables < ActiveRecord::Migration
  def change
    create_table :online_failures do |t|
      t.text :data, null: false
      t.timestamps null: false
    end

    create_table :online_applications do |t|
      t.boolean :applicant_married # marital_status_married
      t.boolean :application_threshold_exceeded # savings_and_investment_less_than_limit
      t.boolean :application_benefits # benefit_on_benefits
      t.boolean :application_descendants
      t.integer :application_children
      t.integer :application_income
      t.boolean :details_refund # fee_paid
      t.string :details_date_fee_paid # fee_date_paid
      t.boolean :details_probate # probate_kase
      t.string :details_deceased_name # probate_deceased_name
      t.string :details_date_of_death # probate_date_of_death
      t.string :details_case_number # claim_number
      t.string :details_form_name # form_name_identifier
      t.string :applicant_ni_number # national_insurance_number
      t.date :applicant_date_of_birth
      t.string :applicant_title # personal_detail_title
      t.string :applicant_first_name # personal_detail_first_name
      t.string :applicant_last_name # personal_detail_last_name
      t.string :applicant_address # applicant_address_address
      t.string :applicant_postcode # applicant_address_postcode
      t.boolean :applicant_email_contact # contact_email_option
      t.string :applicant_email_address # contact_email
      t.boolean :applicant_phone_contact # contact_phone_option
      t.string :applicant_phone # contact_phone
      t.string :applicant_post_contact # contact_post_option
      t.timestamps null: false
    end
  end
end
