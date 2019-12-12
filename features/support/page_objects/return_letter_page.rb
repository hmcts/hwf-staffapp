class ReturnLetterPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Processing complete'
    element :evidence_confirmation_letter, '.evidence-confirmation-letter'
    section :evidence_next_steps, '.evidence-letter-next-steps' do
      element :header, 'h2', text: 'Next steps'
      element :not_received_text, 'p', text: 'Update the case management system for this Help with Fees application'
      element :evidence_incorrect_text, 'p', text: 'Update the case management system noting the reasons why evidence is incorrect'
      element :citizen_not_proceeding_text, 'p', text: 'Update the case management system noting the explanation for not proceeding with this Help with Fees application'
      element :link, 'a', text: 'See the guides'
    end
  end
end
