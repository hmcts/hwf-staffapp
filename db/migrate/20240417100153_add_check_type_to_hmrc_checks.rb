class AddCheckTypeToHmrcChecks < ActiveRecord::Migration[7.1]
  def change
    add_column :hmrc_checks, :check_type, :string, default: 'applicant'
  end
end
