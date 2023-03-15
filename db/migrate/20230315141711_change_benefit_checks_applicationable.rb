class ChangeBenefitChecksApplicationable < ActiveRecord::Migration[7.0]
  def up
    change_column :benefit_checks, :applicationable_id, :integer
    add_index :benefit_checks, [:applicationable_id, :applicationable_type], name: 'index_bc_applicationable_id_type'
  end

  def down
    change_column :benefit_checks, :applicationable_id, :bigint
    remove_index :benefit_checks, [:applicationable_id, :applicationable_type], name: 'index_bc_applicationable_id_type'
  end
end
