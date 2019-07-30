class EvidencePage < BasePage
  section :content, '#content' do
    element :header, 'h2', text: 'Income'
    element :eligable_header, 'h3', text: '✓ Eligible for help with fees'
    element :not_eligable_header, 'h3', text: '✗ Not eligible for help with fees'
    element :part_payment, 'h3', text: 'The applicant must pay £205 towards the fee'
    section :evidence_summary, '.summary-section' do
      element :evidence_header, 'h4', text: 'Evidence'
      element :change_application_evidence, '.column-one-third', text: 'Change application evidence'
      element :correct, '.grid-row', text: 'Correct Yes'
      element :income, '.grid-row', text: 'Income £500'
    end
  end
end
