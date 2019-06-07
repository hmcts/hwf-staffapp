class AddEmergencyReasonToApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :emergency_reason, :string
  end
end
