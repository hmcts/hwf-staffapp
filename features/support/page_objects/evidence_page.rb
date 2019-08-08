class EvidencePage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Income'
    element :eligable_header, 'h3', text: '✓ Eligible for help with fees'
    element :not_eligable_header, 'h3', text: '✗ Not eligible for help with fees'
    element :part_payment, 'h3', text: 'The applicant must pay £205 towards the fee'
    section :evidence_summary, '.govuk-summary-list' do
      element :evidence_header, 'h2', text: 'Evidence'
      element :change_application_evidence, '.govuk-summary-list__actions', text: 'Change'
      elements :evidence_answer_key, '.govuk-summary-list__key'
      elements :evidence_answer_value, '.govuk-summary-list__value'
    end
  end
end
