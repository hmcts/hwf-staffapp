class RemoveBeCodeNotNull < ActiveRecord::Migration
  def up
    change_column :business_entities, :be_code, :string, null: true
    remove_index :business_entities, :be_code
  end

  def down
    change_column :business_entities, :be_code, :string, null: false
    add_index :business_entities, :be_code
  end
end
