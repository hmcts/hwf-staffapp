class AddRemovedReasonToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :removed_reason, :string, null: true
  end
end
