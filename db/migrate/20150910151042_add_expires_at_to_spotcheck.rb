class AddExpiresAtToSpotcheck < ActiveRecord::Migration[5.2]
  def up
    add_column :spotchecks, :expires_at, :datetime

    migrate_sql = <<-SQL.gsub(/^\s+\|/, '')
      |UPDATE spotchecks
      |SET expires_at =
      |  created_at + CAST('#{Settings.evidence_check.expires_in_days} days' AS INTERVAL);
    SQL
    execute(migrate_sql)

    change_column_null :spotchecks, :expires_at, false
  end

  def down
    remove_column :spotchecks, :expires_at
  end
end
