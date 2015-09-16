class AddReferenceToApplicationAndDropReferences < ActiveRecord::Migration
  def up
    # later on, this column would ideally be set to NOT NULL
    add_column :applications, :reference, :string, null: true
    add_index :applications, :reference, unique: true

    migrate_sql = <<SQL
UPDATE applications
SET "reference" = "references".reference
FROM "references"
WHERE applications.id = "references".application_id;
SQL
    execute(migrate_sql)

    drop_table :references
  end

  def down
    create_table :references do |t|
      t.references :application, index: true, null: false
      t.string     :reference, null: false

      t.timestamps
    end

    migrate_sql = <<SQL
INSERT INTO "references"
(application_id, reference, created_at, updated_at)
  SELECT id, reference, created_at, NOW()
  FROM applications
  WHERE CHAR_LENGTH(reference) > 0;
SQL
    execute(migrate_sql)

    remove_index :applications, column: :reference
    remove_column :applications, :reference
  end
end
