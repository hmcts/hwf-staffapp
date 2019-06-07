class AddChildrenToApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :children, :integer
  end
end
