class AddPurgedAtToDwpApiCalls < ActiveRecord::Migration[8.1]
  def change
    add_column :dwp_api_calls, :purged_at, :datetime
  end
end
