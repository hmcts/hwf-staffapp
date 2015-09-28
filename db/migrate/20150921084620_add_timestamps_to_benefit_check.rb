class AddTimestampsToBenefitCheck < ActiveRecord::Migration
  def up
    change_table(:benefit_checks) { |t| t.timestamps }
    migrate_sql = <<-SQL.gsub(/^\s+\|/, '')
      |UPDATE benefit_checks
      |SET
      |  created_at = "applications"."created_at",
      |  updated_at = "applications"."updated_at"
      |FROM "applications"
      |WHERE "applications"."id" = "benefit_checks"."application_id";
    SQL
    execute(migrate_sql)
  end

  def down
    remove_column :benefit_checks, :created_at
    remove_column :benefit_checks, :updated_at
  end
end
