class ConfirmationPage < BasePage
  section :content, '#content' do
    element :reference_number_is, '.govuk-panel__body', text: 'Reference number'
    element :reference_number, '.reference-number'
    element :eligible, 'h2', text: '✓ Eligible for help with fees'
    element :ineligible, 'h2', text: '✗ Not eligible for help with fees'
    element :part_payment, '.callout.callout-part'
    element :failed_benefits, '.govuk-summary-list__row', text: '✗ Failed'
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
    element :next, 'a', text: 'Next'
    element :total_income, 'p', text: /Your income total|Your total monthly income|Your average income for the last 3 months/
    element :fee_to_pay, 'p', text: /Amount you need to pay|Fee to pay/
    element :total_savings, 'p', text: /Your savings and investments total/
    element :max_savings, 'p', text: /Maximum amount of savings and investments allowed/
    element :part_payment_sentence, 'p', text: /The application has been processed for the fee of/
    element :application_complete, 'h1', text: 'Application complete'
    elements :summary_list_row, '.govuk-summary-list__row'
    element :confirmation_letter, '.confirmation-letter'
    section :override, '#override_panel' do
      element :no_reason_error, '.govuk-error-message', text: 'Please select a reason for granting help with fees'
      element :paper_evidence_option, '.govuk-radios__item', text: 'You\'ve received paper evidence that the applicant is receiving benefits'
      element :other_option, '.govuk-radios__item', text: 'Other'
      element :update_application_button, 'input[value="Update application"]'
      element :other_reason_textbox, '.govuk-textarea'
      element :delivery_manager_option, '.govuk-radios__item', text: 'Your delivery manager has allowed discretion with this application'
      element :dwp_option, '.govuk-radios__item', text: 'You want to check if the applicant is receiving benefits using the DWP checker (and it was unavailable when the application was first processed)'
    end
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end
end
