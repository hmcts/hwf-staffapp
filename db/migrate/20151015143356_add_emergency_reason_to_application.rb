class AddEmergencyReasonToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :emergency_reason, :string
  end
end
