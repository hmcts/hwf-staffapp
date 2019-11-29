class EvidencePage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Income'
    element :eligable_header, 'h2', text: '✓ Eligible for help with fees'
    element :not_eligable_header, 'h2', text: '✗ Not eligible for help with fees'
    element :part_payment, 'h2', text: 'The applicant must pay £205 towards the fee'
    element :evidence_can_not_be_processed, 'summary.govuk-details__summary', text: 'What to do if the evidence can’t be processed'
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
  end
end
