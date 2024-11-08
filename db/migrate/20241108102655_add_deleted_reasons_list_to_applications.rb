class AddDeletedReasonsListToApplications < ActiveRecord::Migration[7.2]
  def change
    add_column :applications, :deleted_reasons_list, :string
  end
end
