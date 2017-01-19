class DecisionMigration
  def run!
    # these queries have to run in this exact order
    ActiveRecord::Base.connection.execute(part_payment_sql)
    ActiveRecord::Base.connection.execute(evidence_check_sql)
    ActiveRecord::Base.connection.execute(application_sql)
  end

  private

  def part_payment_sql
    <<-SQL.gsub(/^\s+\|/, '')
      |UPDATE applications
      |SET decision    = REPLACE(part_payments.outcome, 'return', 'none'),
      |  decision_type = 'part_payment'
      |FROM part_payments
      |WHERE
      |  part_payments.application_id = applications.id AND
      |  part_payments.completed_at IS NOT NULL AND
      |  applications.state = #{Application.states[:processed]} AND
      |  applications.decision IS NULL
    SQL
  end

  def evidence_check_sql
    <<-SQL.gsub(/^\s+\|/, '')
      |UPDATE applications
      |SET decision    = REPLACE(evidence_checks.outcome, 'return', 'none'),
      |  decision_type = 'evidence_check'
      |FROM evidence_checks
      |WHERE
      |  evidence_checks.application_id = applications.id AND
      |  evidence_checks.completed_at IS NOT NULL AND
      |  applications.state = #{Application.states[:processed]} AND
      |  applications.decision IS NULL
    SQL
  end

  def application_sql
    <<-SQL.gsub(/^\s+\|/, '')
      |UPDATE applications
      |SET decision    = outcome,
      |  decision_type = 'application'
      |WHERE
      |  state = 3 AND
      |  decision IS NULL
    SQL
  end
end
