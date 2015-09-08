class RemoveSecureRandomAndReferenceHashFromReference < ActiveRecord::Migration
  def change
    remove_column :references, :secure_random, :binary
    remove_column :references, :reference_hash, :string
  end
end
