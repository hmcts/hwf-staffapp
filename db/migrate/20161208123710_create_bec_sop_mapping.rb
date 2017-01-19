class CreateBecSopMapping < ActiveRecord::Migration
  def up
    add_column :business_entities, :sop_code, :string
    rename_column :business_entities, :code, :be_code
  end

  def down
    rename_column :business_entities, :be_code, :code
    remove_column :business_entities, :sop_code, :string
  end
end
