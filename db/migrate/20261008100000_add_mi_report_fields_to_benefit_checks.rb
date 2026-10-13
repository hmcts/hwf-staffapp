class AddMiReportFieldsToBenefitChecks < ActiveRecord::Migration[8.1]
  def change
    change_table :benefit_checks, bulk: true do |t|
      t.string :checker
      t.string :benefit_types
      t.string :claim_status
      t.integer :take_home_pay
    end
  end
end
