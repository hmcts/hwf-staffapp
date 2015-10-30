class RemoveR2Calculator < ActiveRecord::Migration
  def change
    drop_table :r2_calculators
  end
end
