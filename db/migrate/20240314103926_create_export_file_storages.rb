class CreateExportFileStorages < ActiveRecord::Migration[7.1]
  def change
    create_table :export_file_storages do |t|
      t.string :name
      t.timestamps
    end
  end
end
