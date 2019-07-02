class SummaryPage < BasePage
  section :content, '#content' do
    element :header, 'h2', text: 'Check details'
    element :complete_processing_button, 'input[value="Complete processing"]'
    sections :summary_section, '.govuk-summary-list' do
      element :change_benefits, 'a', text: 'ChangeBenefits declared in application'
    end
  end

  def go_to_summary_page
    start_application
    personal_details_page.submit_all_personal_details
    application_details_page.submit_fee_600
    savings_investments_page.submit_less_than
    benefits_page.submit_benefits_yes
    paper_evidence_page.submit_evidence_yes
  end

  def complete_processing
    content.complete_processing_button.click
  end
end
