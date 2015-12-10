class AddDeletedAtAndDeletedByToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :deleted_at, :datetime
    add_reference :applications, :deleted_by, references: :users
  end
end
