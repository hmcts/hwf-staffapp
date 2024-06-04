class AddDiscretionToOnlineApplication < ActiveRecord::Migration[7.1]
  def change
    add_column :online_applications, :discretion_applied, :boolean
    add_column :online_applications, :discretion_manager_name, :string
    add_column :online_applications, :discretion_reason, :string
  end
end
