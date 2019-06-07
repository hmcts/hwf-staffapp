class AddValidDatesToBusinessEntity < ActiveRecord::Migration[5.2]
  def up
    add_column :business_entities, :valid_from, :datetime
    add_column :business_entities, :valid_to, :datetime
    remove_index :business_entities, name: :unique_office_jurisdiction
    add_index :business_entities, [:office_id, :jurisdiction_id, :valid_to], unique: true, name: :unique_active_office_jurisdiction
    execute('UPDATE business_entities SET valid_from = \'2015-01-01\'')
  end

  def down
    remove_column :business_entities, :valid_from
    remove_column :business_entities, :valid_to
    remove_index :business_entities, name: :unique_active_office_jurisdiction
    add_index :business_entities, [:office_id, :jurisdiction_id], unique: true, name: :unique_office_jurisdiction
  end
end
