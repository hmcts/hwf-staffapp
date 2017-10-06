module HomeHelper
  def path_for_application_based_on_state(application)
    case application.state
    when "waiting_for_evidence"
      waiting_for_evidence_path(application)
    when "waiting_for_part_payment"
      waiting_for_part_payment(application)
    when "processed"
      processed_application_path(application)
    when "deleted"
      deleted_application_path(application)
    end
  end

  private

  def waiting_for_evidence_path(application)
    record = Views::ApplicationList.new(application.evidence_check)
    application_link(record)
  end

  def waiting_for_part_payment(application)
    record = Views::ApplicationList.new(application.part_payment)
    application_link(record)
  end

  def application_link(record)
    evidence_path(record.evidence_or_part_payment)
  end
end
