class CreateSpotchecks < ActiveRecord::Migration
  def change
    create_table :spotchecks do |t|
      t.references :application, index: true, null: false

      t.timestamps
    end
  end
end
