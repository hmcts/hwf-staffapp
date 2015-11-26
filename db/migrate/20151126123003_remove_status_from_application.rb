class RemoveStatusFromApplication < ActiveRecord::Migration
  def change
    remove_column :applications, :status, :string
  end
end
