class AddCorrectAndIncorrectReasonToPayment < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :correct, :boolean, null: true
    add_column :payments, :incorrect_reason, :string, null: true
  end
end
