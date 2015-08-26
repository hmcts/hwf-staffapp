class AddReferenceToReference < ActiveRecord::Migration
  def change
    add_column :references, :reference, :string
  end
end
