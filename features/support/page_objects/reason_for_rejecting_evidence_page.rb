class ReasonForRejectingEvidencePage < BasePage
  set_url_matcher %r{/evidence/accuracy_incorrect_reason/[0-9]+}

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
    element :next, 'input[value="Next"]'
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end
end
