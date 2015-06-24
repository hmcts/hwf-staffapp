class AddJurisdictionIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :jurisdiction_id, :integer
    add_foreign_key :users, :jurisdictions
  end
end
