class AddReferenceToReference < ActiveRecord::Migration[5.2]
  def change
    add_column :references, :reference, :string, index: true, null: false
  end
end
