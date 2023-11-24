class AddNewFieldsToOnlineApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :online_applications, :partner_first_name, :string
    add_column :online_applications, :partner_last_name, :string
    add_column :online_applications, :partner_date_of_birth, :date
    add_column :online_applications, :children_age_band, :string

    add_column :online_applications, :calculation_scheme, :string
    add_column :online_applications, :applying_on_behalf, :string
    add_column :online_applications, :partner_ni_number, :string
    add_column :online_applications, :legal_representative, :boolean

    add_column :online_applications, :legal_representative_first_name, :string
    add_column :online_applications, :legal_representative_last_name, :string
    add_column :online_applications, :legal_representative_email, :string
    add_column :online_applications, :legal_representative_organisation_name, :string
    add_column :online_applications, :legal_representative_feedback_opt_in, :string
    add_column :online_applications, :legal_representative_street, :string
    add_column :online_applications, :legal_representative_postcode, :string
    add_column :online_applications, :legal_representative_town, :string
    add_column :online_applications, :legal_representative_address, :string
    add_column :online_applications, :over_16, :boolean
    add_column :online_applications, :statement_signed_by, :string
  end
end
