class StatusMigration
  def run!
    ActiveRecord::Base.connection.execute(evidence_check_sql)
    ActiveRecord::Base.connection.execute(part_payment_sql)
    ActiveRecord::Base.connection.execute(decided_sql)
  end

  private

  def evidence_check_sql
    <<-SQL.gsub(/^\s+\|/, '')
UPDATE applications
SET state = #{Application.states[:evidence_check]}
FROM evidence_checks
WHERE
  applications.id = evidence_checks.application_id
  AND applications.outcome IS NOT NULL
  AND evidence_checks.completed_at IS NULL
    SQL
  end

  def part_payment_sql
    <<-SQL.gsub(/^\s+\|/, '')
UPDATE applications
SET state = #{Application.states[:part_payment]}
FROM part_payments
WHERE
  applications.id = part_payments.application_id
  AND applications.outcome IS NOT NULL
  AND part_payments.completed_at IS NULL
    SQL
  end

  # rubocop:disable MethodLength
  def decided_sql
    <<-SQL.gsub(/^\s+\|/, '')
UPDATE applications
SET state = #{Application.states[:processed]}
WHERE
  applications.outcome IS NOT NULL
  AND
  (
    NOT EXISTS(
        SELECT *
        FROM evidence_checks
        WHERE evidence_checks.application_id = applications.id
              AND evidence_checks.completed_at IS NULL
    )
  )
  AND
  (
    NOT EXISTS(
        SELECT *
        FROM part_payments
        WHERE part_payments.application_id = applications.id
              AND part_payments.completed_at IS NULL
    )
  )
    SQL
  end
end
