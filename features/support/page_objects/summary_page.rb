class SummaryPage < BasePage
  section :content, '#content' do
    element :header, 'h2', text: 'Check details'
    element :complete_processing_button, 'input[value="Complete processing"]'
  end

  def complete_processing
    content.complete_processing_button.click
  end
end
