class RemoveR2Calculator < ActiveRecord::Migration[5.2]
  def change
    drop_table :r2_calculators
  end
end
