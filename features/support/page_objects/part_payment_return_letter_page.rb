class PartPaymentReturnLetterPage < BasePage
  section :content, '#content' do
    element :processing_complete_banner, 'h1', text: 'Processing complete'
    element :back_to_start_button, 'a', text: "Back to start"
    element :next_steps_header, 'h2', text: 'Next steps'
    element :next_steps_line_1, 'p', text: 'Write to applicant using the template provided'
    element :next_steps_line_2, 'p', text: 'Add the reference to the letter'
    element :next_steps_line_3, 'p', text: 'Post the letter and all the documents back to the applicant'
    element :see_guides, 'a', text: 'See the guides'
    section :letter_template, '.evidence-confirmation-letter' do
      element :explanation, 'p', text: /As we haven’t received payment, we’re unable to process your application/
    end
  end
end
