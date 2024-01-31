class PartPaymentReadyToProcessPage < BasePage
  include ActionView::Helpers::NumberHelper
  set_url_matcher %r{/part_payments/[0-9]+/accuracy}

  section :content, '#content' do
    element :no, 'label', text: 'No'
    element :yes, 'label', text: 'Yes'
    element :header, 'h1', text: 'Is the part-payment ready to process?'
    element :evidence_confirmation_letter, '.evidence-confirmation-letter', text: 'We have received your part-payment towards your fee. However we are unable to accept it because:'
    element :return_application_button, 'a', text: 'Return application'
    element :next, 'input[value="Next"]'
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


