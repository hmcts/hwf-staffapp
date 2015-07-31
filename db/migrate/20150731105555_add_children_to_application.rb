class AddChildrenToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :children, :integer
  end
end
