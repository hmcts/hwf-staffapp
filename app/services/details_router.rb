class DetailsRouter
  include Rails.application.routes.url_helpers

  attr_reader :application

  def initialize(application)
    @application = application
  end

  def approval_or_continue
    if needs_approval?
      approval_page
    else
      savings_or_summary
    end
  end

  def savings_or_summary
    if continue_with_discretion_applied?
      application_savings_investments_path(application)
    else
      application_summary_path(application)
    end
  end

  private

  def approval_page
    application_approve_path(application)
  end

  def continue_with_discretion_applied?
    application.detail.discretion_applied != false
  end

  def needs_approval?
    application.detail.fee >= Settings.fee_approval_threshold
  end
end
