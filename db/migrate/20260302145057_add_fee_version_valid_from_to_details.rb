class AddFeeVersionValidFromToDetails < ActiveRecord::Migration[8.1]
  def change
    add_column :details, :fee_version_valid_from, :date
  end
end
