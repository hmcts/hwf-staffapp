class AddOutcomeToPartPayment < ActiveRecord::Migration
  def change
    add_column :part_payments, :outcome, :string
  end
end
