class ConfirmationPage < BasePage
  section :content, '#content' do
    element :reference_number_is, '.govuk-panel__body', text: 'Reference number'
    element :reference_number, '.reference-number'
    element :eligible, 'h2', text: '✓ Eligible for help with fees'

    element :next_steps_steps, 'h2', text: 'Next steps'
    element :write_ref, 'p', text: 'Write the reference number on the top right corner of the paper form'
    element :copy_ref, 'p', text: 'Copy the reference number into the case management system'
    element :can_be_issued, 'p', text: 'The applicant’s process can now be issued'
    element :see_guides, 'a', text: 'See the guides'
  end

  def go_to_confirmation_page
    start_application
    personal_details_page.submit_all_personal_details_ni
    application_details_page.submit_fee_600
    savings_investments_page.submit_less_than
    benefits_page.submit_benefits_yes
    paper_evidence_page.submit_evidence_yes
    click_on 'Complete processing'
  end
end
