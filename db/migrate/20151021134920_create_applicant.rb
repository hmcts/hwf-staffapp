class CreateApplicant < ActiveRecord::Migration[5.2]
  def up
    create_table :applicants do |t|
      t.references :application, index: true, null: false

      table_columns(t)

      t.timestamps null: false
    end

    migrate_sql = <<SQL
INSERT INTO applicants (application_id, title, first_name, last_name, date_of_birth, ni_number, married, created_at, updated_at)
SELECT id, title, first_name, last_name, date_of_birth, ni_number, married, NOW(), NOW()
FROM applications
SQL
    execute(migrate_sql)

    change_table :applications do |t|
      t.remove :title
      t.remove :first_name
      t.remove :last_name
      t.remove :date_of_birth
      t.remove :ni_number
      t.remove :married
    end
  end

  def down
    change_table :applications do |t|
      table_columns(t)
    end

    migrate_sql = <<SQL
UPDATE applications
SET title =          applicants.title,
    first_name =     applicants.first_name,
    last_name =      applicants.last_name,
    date_of_birth =  applicants.date_of_birth,
    ni_number =      applicants.ni_number,
    married =        applicants.married
FROM applicants
WHERE applications.id = applicants.application_id
SQL
    execute(migrate_sql)

    drop_table :applicants
  end

  private

  def table_columns(t)
    t.string  :title
    t.string  :first_name
    t.string  :last_name
    t.date    :date_of_birth
    t.string  :ni_number
    t.boolean :married
  end
end
