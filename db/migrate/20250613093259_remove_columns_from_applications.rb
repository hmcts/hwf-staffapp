class RemoveColumnsFromApplications < ActiveRecord::Migration[8.0]
  def change
    remove_column :applications, :threshold, :string
    remove_column :applications, :threshold_exceeded, :string
    remove_column :applications, :high_threshold_exceeded, :string
  end
end
