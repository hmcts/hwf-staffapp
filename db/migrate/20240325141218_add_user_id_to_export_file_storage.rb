class AddUserIdToExportFileStorage < ActiveRecord::Migration[7.1]
  def change
    add_column :export_file_storages, :user_id, :integer
  end
end
