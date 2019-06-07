class CreateEvidenceCheckFlag < ActiveRecord::Migration[5.2]
  def change
    create_table :evidence_check_flags do |t|
      t.string :ni_number
      t.boolean :active, default: true
      t.integer :count
      t.timestamps null: false
    end

    add_index :evidence_check_flags, [:ni_number, :active], name: 'evidence_check_flags_active_unique', unique: true, where: "active = true"
  end
end
