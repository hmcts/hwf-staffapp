class AddDefaultValueToAmountToPay < ActiveRecord::Migration[8.0]
  def change
    change_column_default :evidence_checks, :amount_to_pay, from: nil, to: 0.0
    change_column_default :applications, :amount_to_pay, from: nil, to: 0.0
  end
end
