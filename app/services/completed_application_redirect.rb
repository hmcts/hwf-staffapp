class CompletedApplicationRedirect
  include Rails.application.routes.url_helpers

  def initialize(application)
    @application = application
  end

  def path
    case @application.state
    when 'processed'
      processed_application_path(@application)
    when 'waiting_for_part_payment'
      part_payment_path(@application.part_payment)
    when 'waiting_for_evidence'
      evidence_check_link
    when 'deleted'
      deleted_application_path(@application)
    end
  end

  def flash_message
    I18n.t(@application.state, scope: 'application_redirect')
  end

  private

  def evidence_check_link
    evidence_check = @application.evidence_check
    return evidence_path(evidence_check) unless evidence_check.hmrc?

    if evidence_check.total_income.try(:positive?)
      evidence_check_hmrc_path(evidence_check, evidence_check.hmrc_check)
    else
      new_evidence_check_hmrc_path(evidence_check)
    end
  end

end
