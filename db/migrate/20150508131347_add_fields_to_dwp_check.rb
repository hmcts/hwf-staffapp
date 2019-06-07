class AddFieldsToDwpCheck < ActiveRecord::Migration[5.2]
  def change
    add_column :dwp_checks, :our_api_token, :string
    add_reference :dwp_checks, :office, index: true, foreign_key: true
    migrate_sql = <<-SQL.gsub(/^\s+\|/, '')
      |UPDATE dwp_checks
      |SET office_id = users.office_id
      |FROM users
      |WHERE users.id = dwp_checks.created_by_id;
    SQL
    execute(migrate_sql)
  end
end
