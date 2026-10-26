class AddNameVariantToBenefitChecks < ActiveRecord::Migration[8.1]
  def change
    add_column :benefit_checks, :name_variant, :string
  end
end
