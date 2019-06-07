class RenamePaymentToPartPayment < ActiveRecord::Migration[5.2]
  def change
    rename_table :payments, :part_payments
  end
end
