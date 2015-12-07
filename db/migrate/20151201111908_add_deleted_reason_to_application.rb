class AddDeletedReasonToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :deleted_reason, :string, null: true
  end
end
