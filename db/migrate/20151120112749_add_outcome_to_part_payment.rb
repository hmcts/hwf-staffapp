class AddOutcomeToPartPayment < ActiveRecord::Migration[5.2]
  def change
    add_column :part_payments, :outcome, :string
  end
end
