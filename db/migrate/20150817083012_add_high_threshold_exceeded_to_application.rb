class AddHighThresholdExceededToApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :high_threshold_exceeded, :boolean
  end
end
