class ConfirmationPage < BasePage
  section :content, '#content' do
    element :reference_number_is, '.govuk-panel__body', text: 'Reference number'
    element :reference_number, '.reference-number'
    element :eligible, 'h2', text: '✓ Eligible for help with fees'
    element :ineligible, 'h2', text: '✗ Not eligible for help with fees'
    element :failed_benefits, '.govuk-summary-list__row', text: '✗ Failed (paper evidence checked)'
    element :passed_benefits, '.govuk-summary-list__row', text: '✓ Passed (paper evidence checked)'
    element :next_steps_steps, 'h2', text: 'Next steps'
    element :outcome_header, 'h2'
    element :write_ref, 'p', text: 'Write the reference number on the top right corner of the paper form'
    element :copy_ref, 'p', text: 'Copy the reference number into the case management system'
    element :can_be_issued, 'p', text: 'The applicant’s process can now be issued'
    element :see_guides, 'a', text: 'See the guides'
    element :grant_hwf, 'span', text: 'Grant help with fees'
    element :passed_by_manager, 'dd', text: '✓ Passed (by manager\'s decision)'
    element :granted_hwf, 'h2', text: '✓ Granted help with fees'
    section :override, '#override_panel' do
      element :no_reason_error, '.govuk-error-message', text: 'Please select a reason for granting help with fees'
      element :paper_evidence_option, '.govuk-radios__item', text: 'You\'ve received paper evidence that the applicant is receiving benefits'
      element :other_option, '.govuk-radios__item', text: 'Other'
      element :update_application_button, 'input[value="Update application"]'
      element :other_reason_textbox, '.govuk-textarea'
    end
    element :next, 'a', text: 'Next'
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end
end
