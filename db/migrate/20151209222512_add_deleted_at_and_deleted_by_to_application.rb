class AddDeletedAtAndDeletedByToApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :deleted_at, :datetime
    add_reference :applications, :deleted_by, references: :users
  end
end
