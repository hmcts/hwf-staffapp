class AddForeignKeysToUserReferences < ActiveRecord::Migration
  def change
    add_user_foreign_key(:applications, :completed_by_id)
    add_user_foreign_key(:applications, :deleted_by_id)

    add_user_foreign_key(:benefit_overrides, :completed_by_id)

    add_user_foreign_key(:evidence_checks, :completed_by_id)

    add_user_foreign_key(:part_payments, :completed_by_id)

    add_user_foreign_key(:users, :invited_by_id)
  end

  def add_user_foreign_key(from_table, column)
    add_foreign_key from_table, :users, column: column, on_update: :cascade
  end
end
