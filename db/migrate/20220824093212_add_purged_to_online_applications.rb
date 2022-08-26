class AddPurgedToOnlineApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :online_applications, :purged, :boolean, default: false
  end
end
