class AddDateReceivedToOnlineApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :online_applications, :date_received, :date
  end
end
