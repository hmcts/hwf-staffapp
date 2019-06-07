class AddJurisdictionIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :jurisdiction_id, :integer
    add_foreign_key :users, :jurisdictions
  end
end
