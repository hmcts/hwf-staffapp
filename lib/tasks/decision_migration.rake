namespace :decisions do

  desc 'Create decisions for completed applications'
  task migrate: :environment do
    applications = Application.where(decision: nil).order(:id)
    puts '-' * 60
    puts "Checking #{applications.count} of #{Application.count} applications without a decision"
    puts '-' * 60
    applications.each do |application|
      @application = application
      decision_type = nil
      decision = nil

      if application.decision.nil?
        if payment_complete?
          # if the part_payment is completed and the application has no decision
          decision_type = 'part_payment'
          decision = application.part_payment.correct ? 'full' : 'none'
        elsif evidence_check_complete?
          # If an evidence_check completed_at is set and there is no part_payment
          decision_type = 'evidence_check'
          decision = evidence_check_outcomes[application.evidence_check.outcome]
        elsif application_complete?
          # If an application has a completed_at date and no evidence_check or part_payments
          decision_type = 'application'
          decision = application.outcome
        end
      end

      if decision && decision_type
        puts ">>> Setting application(#{application.id}) to '#{decision}' and '#{decision_type}'"
        application.update_attributes(decision_type: decision_type,
                                      decision: decision)
      else
        puts failure_reason
      end
    end
    puts '-' * 60
  end

  def payment_complete?
    exists_and_completed_at_is?('part_payment', 'present?')
  end

  def evidence_check_complete?
    @application.part_payment.nil? && exists_and_completed_at_is?('evidence_check', 'present?')
  end

  def application_complete?
    @application.part_payment.nil? && @application.evidence_check.nil? &&
      @application.completed_at.present?
  end

  def failure_reason
    output = "*** Application(#{@application.id}) could not be set because "
    output += 'it has an unfinished payment' if payment_incomplete?
    output += 'it has an unfinished evidence_check' if evidence_check_incomplete?
    output += 'it has not been completed' if application_incomplete?
    output
  end

  def payment_incomplete?
    exists_and_completed_at_is?('part_payment', 'nil?')
  end

  def evidence_check_incomplete?
    @application.part_payment.nil? && exists_and_completed_at_is?('evidence_check', 'nil?')
  end

  def application_incomplete?
    @application.part_payment.nil? && @application.evidence_check.nil? &&
      @application.completed_at.nil?
  end

  def exists_and_completed_at_is?(attribute, value)
    @application.send("#{attribute}?") && @application.send("#{attribute}").completed_at.send(value)
  end

  def evidence_check_outcomes
    { 'full' => 'full',
      'part' => 'part',
      'none' => 'none',
      'return' => 'none',
      'undetermined' => 'none' }
  end
end
