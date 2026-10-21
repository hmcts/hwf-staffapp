class AddDateOfDeathToBenefitChecks < ActiveRecord::Migration[8.1]
  def change
    add_column :benefit_checks, :date_of_death, :date
  end
end
