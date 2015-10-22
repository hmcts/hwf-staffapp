class CreateBenefitOverrides < ActiveRecord::Migration
  def change
    create_table :benefit_overrides do |t|
      t.references :application, index: true, null: false
      t.boolean :correct
      t.integer :completed_by_id

      t.timestamps null: false
    end

    add_foreign_key :benefit_overrides, :applications
  end
end
