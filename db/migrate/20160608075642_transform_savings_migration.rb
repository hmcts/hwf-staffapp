class TransformSavingsMigration < ActiveRecord::Migration[5.2]
  def up
    SavingsTransformation.new.up!
  end

  def down
  end
end
