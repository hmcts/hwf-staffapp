class TransformSavingsMigration < ActiveRecord::Migration
  def up
    SavingsTransformation.new.up!
  end

  def down
  end
end
