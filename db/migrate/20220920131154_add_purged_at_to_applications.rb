class AddPurgedAtToApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :applications, :purged_at, :date
    add_column :online_applications, :purged_at, :date
  end
end
