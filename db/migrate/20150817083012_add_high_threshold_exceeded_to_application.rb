class AddHighThresholdExceededToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :high_threshold_exceeded, :boolean
  end
end
