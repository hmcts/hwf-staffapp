class ConfirmationPage < BasePage
  section :content, '#content' do
    element :eligible, 'h3', text: '✓ Eligible for help with fees'
    element :complete_processing_button, 'input[value="Complete processing"]'
    element :back_to_start, 'a', text: 'Back to start'
  end

  def back_to_start
    content.back_to_start.click
  end
end
