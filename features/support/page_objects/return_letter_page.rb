class ReturnLetterPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Processing complete'
    element :evidence_confirmation_letter, '.evidence-confirmation-letter'
    section :evidence_next_steps, '.evidence-letter-next-steps' do
      element :header, 'h2', text: 'Next steps'
      element :text, 'p', text: 'Write to the applicant using the letter on this page'
      element :link, 'a', text: 'See the guides'
    end
  end
end
