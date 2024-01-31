class PartPaymentConfirmationPage < BasePage
  include ActionView::Helpers::NumberHelper
  set_url_matcher %r{/part_payments/[0-9]+/confirmation}

  section :content, '#content' do
    element :processed_header, 'h1', text: 'Processing complete'
    element :complete, 'input[value="Complete processing"]'
  end

end
