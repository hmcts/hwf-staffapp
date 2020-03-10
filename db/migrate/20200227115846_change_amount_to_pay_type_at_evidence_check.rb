class ChangeAmountToPayTypeAtEvidenceCheck < ActiveRecord::Migration[5.2]
  def up
    change_column :evidence_checks, :amount_to_pay, :decimal
  end

  def down
    change_column :evidence_checks, :amount_to_pay, :integer
  end
end
