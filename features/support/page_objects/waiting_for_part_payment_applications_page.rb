class WaitingForPartPaymentApplicationsPage < BasePage
  set_url '/part_payments'

  section :content, '#content' do
    element :header, 'h1', text: 'Waiting for part-payments'
    element :no_applications, 'p', text: 'There are no applications waiting for part-payment'
  end
end
