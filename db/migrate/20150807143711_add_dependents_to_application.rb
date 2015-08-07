class AddDependentsToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :dependents, :boolean
  end
end
