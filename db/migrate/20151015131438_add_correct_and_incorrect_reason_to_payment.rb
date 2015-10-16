class AddCorrectAndIncorrectReasonToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :correct, :boolean, null: true
    add_column :payments, :incorrect_reason, :string, null: true
  end
end
