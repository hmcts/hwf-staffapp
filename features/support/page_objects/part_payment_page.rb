class PartPaymentPage < BasePage
  section :content, '#content' do
    element :no, 'label', text: 'No'
    element :yes, 'label', text: 'Yes'
    element :evidence_confirmation_letter, '.evidence-confirmation-letter', text: 'We have received your part-payment towards your fee. However we are unable to accept it because:'
  end

  def ready_to_process_payment
    content.yes.click
    next_page
  end

  def not_ready_to_process_payment
    content.no.click
    fill_in 'Describe the problem with the part-payment', with: 'No signature on cheque'
    next_page
  end
end
