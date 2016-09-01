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
      evidence_path(@application.evidence_check)
    when 'deleted'
      deleted_application_path(@application)
    end
  end

  def flash_message
    I18n.t(@application.state, scope: 'application_redirect')
  end
end
