class ReasonForRejectingEvidencePage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'What is the reason for rejecting the evidence?'
    element :hint, '.govuk-hint', text: 'Select all that apply.'
    element :requested_sources_not_provided, '.govuk-label', text: 'Requested sources not provided'
    element :wrong_type_provided, '.govuk-label', text: 'Wrong type provided'
    element :unreadable_illegible, '.govuk-label', text: 'Unreadable or illegible'
    element :pages_missing, '.govuk-label', text: 'Pages missing'
    element :cannot_identify_applicant, '.govuk-label', text: 'Cannot identify applicant'
    element :wrong_date_range, '.govuk-label', text: 'Wrong date range'
    element :error, '.error', text: 'Please select from one of the options'
  end

  def go_to_reason_for_rejecting_evidence_page
    waiting_evidence_application_ni
    waiting_evidence_application_ni
    click_link "#{reference_prefix}-000002"
    click_on 'Start now', visible: false
    evidence_accuracy_page.content.problem_with_evidence.click
    click_on 'Next', visible: false
  end
end
