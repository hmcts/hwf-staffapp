class ChangeAmountToPayType < ActiveRecord::Migration[5.2]
  def up
    change_column :applications, :amount_to_pay, :decimal
  end

  def down
    change_column :applications, :amount_to_pay, :integer
  end
end
