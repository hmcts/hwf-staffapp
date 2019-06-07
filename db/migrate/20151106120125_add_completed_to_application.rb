class AddCompletedToApplication < ActiveRecord::Migration[5.2]
  def up
    add_column :applications, :completed_at, :datetime
    add_reference :applications, :completed_by, references: :users
    migrate_sql = <<-SQL.gsub(/^\s+\|/, '')
      |UPDATE applications
      |SET
      |  completed_at = "applications"."updated_at",
      |  completed_by_id = "applications"."user_id"
      |WHERE application_outcome IS NOT NULL AND
      |  status IS NOT NULL AND
      |  application_type IS NOT NULL;
    SQL
    execute(migrate_sql)
  end

  def down
    remove_column :applications, :completed_at
    remove_column :applications, :completed_by
  end
end
