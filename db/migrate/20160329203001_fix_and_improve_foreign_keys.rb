class FixAndImproveForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key :applicants, :applications, on_update: :cascade

    change_foreign_key :applications, :business_entities
    change_foreign_key :applications, :offices
    change_foreign_key :applications, :users

    change_foreign_key :benefit_checks, :applications
    change_foreign_key :benefit_checks, :users

    change_foreign_key :benefit_overrides, :applications

    add_foreign_key :business_entities, :jurisdictions, on_update: :cascade
    add_foreign_key :business_entities, :offices, on_update: :cascade

    add_foreign_key :details, :applications, on_update: :cascade
    add_foreign_key :details, :jurisdictions, on_update: :cascade

    add_foreign_key :evidence_checks, :applications, on_update: :cascade

    change_foreign_key :feedbacks, :offices
    change_foreign_key :feedbacks, :users

    change_foreign_key :office_jurisdictions, :jurisdictions
    change_foreign_key :office_jurisdictions, :offices

    add_foreign_key :part_payments, :applications, on_update: :cascade

    change_foreign_key :users, :jurisdictions
    change_foreign_key :users, :offices

    # some extra foreign references to the users table

    add_user_foreign_key(:applications, :completed_by_id)
    add_user_foreign_key(:applications, :deleted_by_id)

    add_user_foreign_key(:benefit_overrides, :completed_by_id)

    add_user_foreign_key(:evidence_checks, :completed_by_id)

    add_user_foreign_key(:part_payments, :completed_by_id)

    # This foreign key can't be setup now as it prevents the primary key to be incremented
    # add_user_foreign_key(:users, :invited_by_id)
  end

  def change_foreign_key(from_table, to_table)
    reversible do |dir|
      dir.up do
        remove_foreign_key from_table, to_table
        add_foreign_key from_table, to_table, on_update: :cascade
      end

      dir.down do
        remove_foreign_key from_table, to_table
        add_foreign_key from_table, to_table
      end
    end
  end

  def add_user_foreign_key(from_table, column)
    add_foreign_key from_table, :users, column: column, on_update: :cascade
  end
end
