class RenamePaymentToPartPayment < ActiveRecord::Migration
  def change
    rename_table :payments, :part_payments
  end
end
