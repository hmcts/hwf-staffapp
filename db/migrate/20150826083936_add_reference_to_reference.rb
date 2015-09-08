class AddReferenceToReference < ActiveRecord::Migration
  def change
    add_column :references, :reference, :string, index: true, null: false
  end
end
