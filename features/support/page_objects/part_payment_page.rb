class PartPaymentPage < BasePage
  section :content, '#content' do
    element :no, 'label', text: 'No'
    element :yes, 'label', text: 'Yes'
    element :header, 'h1', text: 'Is the part-payment ready to process?'
    element :evidence_confirmation_letter, '.evidence-confirmation-letter', text: 'We have received your part-payment towards your fee. However we are unable to accept it because:'
    element :part_payment_fee, '#result h2', text: 'The applicant must pay £40 towards the fee'
    element :not_received, 'span', text: 'What to do when a part payment has not been received'
    element :return_application_button, 'input[type="submit"][value="Return application"]'
    element :next, 'input[value="Next"]'
    element :back_to_start_link, 'a', text: 'Back to start'
    element :next_steps_header, 'h2', text: 'Next steps'
    element :next_steps_line_1, 'p', text: 'Write to applicant using the template provided'
    element :next_steps_line_2, 'p', text: 'Add the reference to the letter'
    element :next_steps_line_3, 'p', text: 'Post the letter and all the documents back to the applicant'
    element :see_guides, 'a', text: 'See the guides'
    element :waiting_for_part_payment_instance_heading, 'h1', text: /Waiting for part-payment$/
    element :start_now_button, 'a', text: 'Start now'
  end

  def ready_to_process_payment
    content.wait_until_yes_visible
    content.yes.click
    click_next
  end

  def not_ready_to_process_payment
    content.wait_until_no_visible
    content.no.click
    fill_in 'Describe the problem with the part-payment', with: 'No signature on cheque'
    click_next
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end
end
