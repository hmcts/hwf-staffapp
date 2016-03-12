class AddDetailsToOnlineApplication < ActiveRecord::Migration
  def change
    change_table :online_applications do |t|
      t.decimal :fee
      t.references :jurisdiction, null: true, index: true, foreign_key: { on_update: :cascade }
      t.text :emergency_reason
    end
  end
end
