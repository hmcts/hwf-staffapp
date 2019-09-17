class CreateDetail < ActiveRecord::Migration[5.2]
  COLUMNS = {
    fee: :decimal,
    jurisdiction_id: :integer,
    date_received: :date,
    form_name: :string,
    case_number: :string,
    probate: :boolean,
    deceased_name: :string,
    date_of_death: :date,
    refund: :boolean,
    date_fee_paid: :date,
    emergency_reason: :string
  }

  def up
    create_table :details do |t|
      t.references :application, index: true, null: false

      add_table_columns(t)

      t.timestamps null: false
    end

    migrate_sql = <<SQL
INSERT INTO details
  (application_id, #{COLUMNS.keys.join(', ')}, created_at, updated_at)
SELECT id, #{COLUMNS.keys.join(', ')}, NOW(), NOW()
FROM applications
SQL
    execute(migrate_sql)

    change_table :applications do |t|
      remove_table_columns(t)
    end
  end

  def down
    change_table :applications do |t|
      add_table_columns(t)
    end

    migrate_sql = <<SQL
UPDATE applications
SET #{sql_update_columns_for_downgrade}
FROM details
WHERE applications.id = details.application_id
SQL
    execute(migrate_sql)

    drop_table :details
  end

  private

  def add_table_columns(table)
    COLUMNS.each do |name, type|
      table.send(type, name)
    end
  end

  def remove_table_columns(table)
    COLUMNS.each do |name, _|
      table.send(:remove, name)
    end
  end

  def sql_update_columns_for_downgrade
    COLUMNS.map do |name, _|
      "#{name} = details.#{name}"
    end.join(', ')
  end
end
