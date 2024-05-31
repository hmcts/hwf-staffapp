class RemoveDiscretionDetailsFromOnlineApplication < ActiveRecord::Migration[7.1]
  def up
    remove_column :online_applications, :discretion_manager_name
    remove_column :online_applications, :discretion_reason
  end

  def down
    add_column :online_applications, :discretion_manager_name, :string
    add_column :online_applications, :discretion_reason, :string
  end
end
