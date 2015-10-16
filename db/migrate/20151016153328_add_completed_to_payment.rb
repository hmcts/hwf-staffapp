class AddCompletedToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :completed_at, :datetime
    add_reference :payments, :completed_by, references: :users
  end
end
