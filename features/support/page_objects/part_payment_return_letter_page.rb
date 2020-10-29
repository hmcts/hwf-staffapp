class PartPaymentReturnLetterPage < BasePage
  section :content, '#content' do
    element :processing_complete_banner, 'h1', text: 'Processing complete'
    element :back_to_start, 'input[value="Back to start"]'
    section :letter_template, '.evidence-confirmation-letter' do
      element :explanation, 'p', text: /As we haven’t received payment, we’re unable to process your application/
    end
  end
end
