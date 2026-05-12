class AddFeeEntryMethodToDetails < ActiveRecord::Migration[8.1]
  def change
    add_column :details, :fee_entry_method, :string
  end
end
