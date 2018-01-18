class AddDiscretionAppliedToApplication < ActiveRecord::Migration
  def up
    add_column :details, :discretion_applied, :boolean
  end

  def down
    remove_column :details, :discretion_applied
  end
end
