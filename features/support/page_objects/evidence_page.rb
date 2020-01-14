class EvidencePage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Income'
    element :eligable_header, 'h2', text: '✓ Eligible for help with fees'
    element :not_eligable_header, 'h2', text: '✗ Not eligible for help with fees'
    element :part_payment, 'h2', text: 'The applicant must pay £205 towards the fee'
    element :evidence_can_not_be_processed, 'summary.govuk-details__summary', text: "What to do if evidence hasn't arrived"
    element :evidence_deadline, '.govuk-details__text'
    sections :evidence_summary, '.govuk-summary-list' do
      element :personal_details, 'h2', text: 'Personal details'
      element :application_details, 'h2', text: 'Application details'
      element :benefits, 'h2', text: 'Benefits'
      element :income, 'h2', text: 'Income'
      element :result, 'h2', text: 'Result'
      elements :summary_row, '.govuk-summary-list__row'
    end
    element :processing_summary, 'h2', text: 'Processing summary'
    elements :table_row, '.govuk-table__row'
    element :error_message, '.govuk-error-summary', text: 'There is a problem This application has been processed. You can’t edit any details.'
  end

  def processed_evidence
    click_link("#{reference_prefix}-000002")
    click_link('Start now')
    evidence_accuracy_page.content.correct_evidence.click
    next_page
    fill_in 'Total monthly income from evidence', with: '500'
    next_page
    click_link('Next')
    complete_processing
  end
end
