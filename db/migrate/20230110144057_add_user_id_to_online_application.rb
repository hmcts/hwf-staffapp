class AddUserIdToOnlineApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :online_applications, :user_id, :integer
  end
end
