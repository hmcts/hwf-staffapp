class AddAndCalculateStatusToApplication < ActiveRecord::Migration[5.2]
  def up
    add_column :applications, :state, :integer, null: false, default: 0

    StateMigration.new.run!
  end

  def down
    remove_column :applications, :state
  end
end
