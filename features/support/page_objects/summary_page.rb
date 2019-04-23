class SummaryPage < BasePage
  section :content, '#content' do
    element :header, 'h2', text: 'Check details'
    element :complete_processing_button, 'input[value="Complete processing"]'
    sections :summary_section, '.summary-section' do
      element :summary_header, 'h4'
      element :benefit_declared_yes, '.grid-row', text: 'Benefits declared in application Yes'
      element :evidence_provided_yes, '.grid-row', text: 'Correct evidence provided Yes'
    end
  end

  def complete_processing
    content.complete_processing_button.click
  end
end
