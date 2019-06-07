class MoveReasonToEvidenceCheck < ActiveRecord::Migration[5.2]
  def up
    add_column :evidence_checks, :incorrect_reason, :string, null: true

    update_query = <<SQL
UPDATE evidence_checks
SET incorrect_reason = reasons.explanation
FROM reasons
WHERE reasons.evidence_check_id = evidence_checks.id
SQL
    execute(update_query)

    drop_table :reasons
  end

  def down
    create_table :reasons do |t|
      t.string :explanation
      t.references :evidence_check, index: true, foreign_key: true
    end

    insert_query = <<SQL
INSERT INTO reasons (explanation, evidence_check_id)
SELECT evidence_checks.incorrect_reason, evidence_checks.id
FROM evidence_checks
WHERE evidence_checks.incorrect_reason IS NOT NULL
SQL
    execute(insert_query)

    remove_column :evidence_checks, :incorrect_reason
  end
end
