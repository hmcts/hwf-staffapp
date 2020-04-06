class SummaryPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Check details'
    element :complete_processing_button, 'input[value="Complete processing"]'
    sections :summary_section, 'dl' do
      element :personal_details_header, 'h2', text: 'Personal details'
      element :evidence_header, 'h2', text: 'Evidence'
      elements :list_row, '.govuk-summary-list__row'
      element :evidence_reason, '.govuk-summary-list__row', text: 'Reason Not arrived or too late'
      element :evidence_incorrect_reason_category, '.govuk-summary-list__row', text: 'Incorrect reason category Requested sources not provided, Wrong type provided, Unreadable or illegible, Pages missing, Cannot identify applicant, Wrong date range Change'
      element :change_benefits, 'a', text: 'ChangeBenefits declared in application'
    end
  end

  def go_to_summary_page_low_savings
    start_application
    personal_details_page.submit_all_personal_details
    application_details_page.submit_fee_600
    savings_investments_page.submit_less_than
    benefits_page.submit_benefits_yes
    paper_evidence_page.submit_evidence_yes
  end

  def go_to_summary_page_high_savings
    start_application
    personal_details_page.submit_all_personal_details
    application_details_page.submit_fee_600
    savings_investments_page.submit_exact_amount
  end
end
