class AddPurgedToApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :applications, :purged, :boolean, default: false
  end
end
