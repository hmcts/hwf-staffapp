class AddApplicationableToBenefitChecks < ActiveRecord::Migration[7.0]
  def change
    add_column :benefit_checks, :applicationable_id,  :bigint
    add_column :benefit_checks, :applicationable_type, :string
  end
end
