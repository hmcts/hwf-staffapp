class AddCompletedToPayment < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :completed_at, :datetime
    add_reference :payments, :completed_by, references: :users
  end
end
