class AddBusinessEntityToApplication < ActiveRecord::Migration
  def up
    add_reference :applications, :business_entity, index: true, null: true, foreign_key: true

    update_sql = <<-SQL.gsub(/^\s+\|/, '')
      |UPDATE applications
      |SET business_entity_id = (
      |  SELECT id
      |  FROM business_entities
      |  WHERE
      |    business_entities.office_id = applications.office_id AND
      |    business_entities.jurisdiction_id = details.jurisdiction_id
      |)
      |FROM details
      |WHERE applications.id = details.application_id
    SQL
    execute(update_sql)
  end

  def down
    remove_reference :applications, :business_entity
  end
end
