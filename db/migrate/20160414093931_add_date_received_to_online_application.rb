class AddDateReceivedToOnlineApplication < ActiveRecord::Migration
  def change
    add_column :online_applications, :date_received, :date
  end
end
