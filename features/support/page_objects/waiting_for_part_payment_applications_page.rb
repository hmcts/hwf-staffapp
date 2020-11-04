class WaitingForPartPaymentApplicationsPage < BasePage

  set_url '/part_payments'

  section :content, '#content' do
    element :header, 'h1'
  end
end
