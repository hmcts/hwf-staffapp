class AddDeletedReasonToApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :deleted_reason, :string, null: true
  end
end
