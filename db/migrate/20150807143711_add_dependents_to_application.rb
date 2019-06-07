class AddDependentsToApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :dependents, :boolean
  end
end
