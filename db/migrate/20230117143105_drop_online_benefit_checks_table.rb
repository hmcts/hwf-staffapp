class DropOnlineBenefitChecksTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :online_benefit_checks
  end
end
