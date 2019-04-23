class ConfirmationPage < BasePage
  section :content, '#content' do
    element :eligible, 'h3', text: '✓ Eligible for help with fees'
    element :complete_processing_button, 'input[value="Complete processing"]'
    element :back_to_start, '.button', text: 'Back to start'
  end

  def go_to_confirmation_page
    start_application
    personal_details_page.submit_all_personal_details
    application_details_page.submit_fee_600
    savings_investments_page.submit_less_than
    benefits_page.submit_benefits_yes
    paper_evidence_page.submit_evidence_yes
    summary_page.complete_processing
  end

  def back_to_start
    content.back_to_start.click
  end
end
