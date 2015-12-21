class DecisionDateAndCostMigration
  def run! # rubocop:disable AbcSize
    # the order of these migration sqls is important
    ActiveRecord::Base.connection.execute(decision_date_part_payment)
    ActiveRecord::Base.connection.execute(decision_date_evidence_check)
    ActiveRecord::Base.connection.execute(decision_date_application)

    ActiveRecord::Base.connection.execute(decision_cost_none)
    ActiveRecord::Base.connection.execute(decision_cost_full)
    ActiveRecord::Base.connection.execute(decision_cost_part_evidence_check)
    ActiveRecord::Base.connection.execute(decision_cost_part_application)
  end

  private

  def decision_date_part_payment
    <<-SQL.gsub(/^\s+\|/, '')
      |UPDATE applications
      |SET decision_date = part_payments.completed_at
      |FROM part_payments
      |WHERE
      |  part_payments.application_id = applications.id AND
      |  applications.state = #{Application.states[:processed]} AND
      |  applications.decision_type LIKE 'part_payment'
    SQL
  end

  def decision_date_evidence_check
    <<-SQL.gsub(/^\s+\|/, '')
      |UPDATE applications
      |SET decision_date = evidence_checks.completed_at
      |FROM evidence_checks
      |WHERE
      |  evidence_checks.application_id = applications.id AND
      |  applications.state = #{Application.states[:processed]} AND
      |  applications.decision_type LIKE 'evidence_check'
    SQL
  end

  def decision_date_application
    <<-SQL.gsub(/^\s+\|/, '')
      |UPDATE applications
      |SET decision_date = completed_at
      |WHERE
      |  applications.state = #{Application.states[:processed]} AND
      |  applications.decision_type LIKE 'application'
    SQL
  end

  def decision_cost_none
    <<-SQL.gsub(/^\s+\|/, '')
      |UPDATE applications
      |SET decision_cost = 0
      |WHERE
      |  applications.state = #{Application.states[:processed]} AND
      |  applications.decision LIKE 'none'
    SQL
  end

  def decision_cost_full
    <<-SQL.gsub(/^\s+\|/, '')
      |UPDATE applications
      |SET decision_cost = details.fee
      |FROM details
      |WHERE
      |  details.application_id = applications.id AND
      |  applications.state = #{Application.states[:processed]} AND
      |  applications.decision LIKE 'full'
    SQL
  end

  def decision_cost_part_evidence_check
    <<-SQL.gsub(/^\s+\|/, '')
      |UPDATE applications
      |SET decision_cost = (details.fee - evidence_checks.amount_to_pay)
      |FROM details, evidence_checks
      |WHERE
      |  details.application_id = applications.id AND
      |  evidence_checks.application_id = applications.id AND
      |  applications.state = #{Application.states[:processed]} AND
      |  applications.decision LIKE 'part'
    SQL
  end

  def decision_cost_part_application
    <<-SQL.gsub(/^\s+\|/, '')
      |UPDATE applications
      |SET decision_cost = (details.fee - amount_to_pay)
      |FROM details
      |WHERE
      |  details.application_id = applications.id AND
      |  applications.state = #{Application.states[:processed]} AND
      |  applications.decision LIKE 'part' AND
      |  applications.decision_cost IS NULL
    SQL
  end
end
