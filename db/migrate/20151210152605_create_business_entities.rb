class CreateBusinessEntities < ActiveRecord::Migration[5.2]
  def up
    create_table :business_entities do |t|
      t.references :office, null: false, index: true
      t.references :jurisdiction, null: false, index: true

      t.string :code, null: false, index: true
      t.string :name, null: false, index: true

      t.timestamps null: false
    end

    add_index :business_entities, [:office_id, :jurisdiction_id], unique: true, name: :unique_office_jurisdiction

    insert_sql = <<-SQL.gsub(/^\s+\|/, '')
      |INSERT INTO business_entities (office_id, jurisdiction_id, code, name, created_at, updated_at)
      |SELECT
      |  offices.id,
      |  jurisdictions.id,
      |  offices.entity_code,
      |  concat_ws(' - ', offices.name, jurisdictions.name),
      |  NOW(),
      |  NOW()
      |FROM offices
      |CROSS JOIN jurisdictions
    SQL
    execute(insert_sql)
  end

  def down
    remove_index :business_entities, name: :unique_office_jurisdiction
    drop_table :business_entities
  end
end
