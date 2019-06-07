class RenameOver61 < ActiveRecord::Migration[5.2]
  def change
    rename_column :applications, :over_61, :partner_over_61
  end
end
