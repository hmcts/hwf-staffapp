class AddDiscretionManagerNameAndDiscretionReasonToDetails < ActiveRecord::Migration
  def up
    add_column :details, :discretion_manager_name, :string
    add_column :details, :discretion_reason, :string
  end

  def down
    remove_column :details, :discretion_manager_name
    remove_column :details, :discretion_reason
  end
end
