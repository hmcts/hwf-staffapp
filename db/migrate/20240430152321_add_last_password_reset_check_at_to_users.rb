class AddLastPasswordResetCheckAtToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :last_password_reset_check_at, :datetime
  end
end
