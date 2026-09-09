class AddReprocessedToBenefitOverrides < ActiveRecord::Migration[8.1]
  def change
    add_column :benefit_overrides, :reprocessed, :boolean, default: false, null: false
  end
end
