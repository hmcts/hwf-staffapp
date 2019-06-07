class AddIncorrectReasonToBenefitOverride < ActiveRecord::Migration[5.2]
  def change
    add_column :benefit_overrides, :incorrect_reason, :string, null: true
  end
end
