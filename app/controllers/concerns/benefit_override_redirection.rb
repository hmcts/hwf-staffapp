module BenefitOverrideRedirection
  extend ActiveSupport::Concern

  private

  # The staff answer can be recorded and the application processed, unless an
  # outage-type DWP failure requires paper evidence and none was provided.
  # When DWP is marked offline staff decide benefits manually, and an
  # InvalidRequest or a DWP data error (2001/1007) is a problem with the
  # applicant's data, not an outage - none of them blocks (CHANGELOG.md). The
  # record is an Application or an OnlineApplication.
  def benefit_override_allowed?(record, evidence_provided:)
    return true if DwpWarning.offline?
    return true if record.last_benefit_check&.invalid_request?
    return true if record.last_benefit_check&.dwp_data_error?
    return true if evidence_provided
    !record.benefit_check_with_error_message?
  end

  def take_user_home
    flash[:alert] = t('error_messages.benefit_check.cannot_process_application')
    redirect_to root_url
  end
end
