class AddIncorrectReasonToBenefitOverride < ActiveRecord::Migration
  def change
    add_column :benefit_overrides, :incorrect_reason, :string, null: true
  end
end
