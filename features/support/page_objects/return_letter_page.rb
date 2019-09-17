class ReturnLetterPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Processing complete'
    element :evidence_confirmation_letter, '.evidence-confirmation-letter'
  end
end
