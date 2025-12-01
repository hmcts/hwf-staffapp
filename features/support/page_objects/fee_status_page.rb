class FeeStatusPage < BasePage
  set_url_matcher %r{/applications/[0-9]+/fee_status}

  section :content, '#content' do
    element :header, 'h1', text: 'Date received and fee status'
    element :application_date_received_error, '.error', text: 'Enter the date in this format DD/MM/YYYY'
    element :application_refund_error, '.error', text: 'Enter if the fee has already been paid'
    element :application_refund_scope_error, '.error', text: 'This fee was paid more than 3 months from the date received. Delivery Manager discretion must be applied to progress this application'
    element :refund_false, '#application_refund_false', visible: false
    element :refund_true, '#application_refund_true'
    element :next, 'input[value="Next"]'
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end

  def fill_in_date_received
    date_received = Time.zone.today - 2.months
    fill_in('Day', with: date_received.day)
    fill_in('Month', with: date_received.month)
    fill_in('Year', with: date_received.year)
  end

  def fill_in_date_payed(months_ago)
    date_paid = Time.zone.today - months_ago

    within('div#refund-only') do
      fill_in('Day', with: date_paid.day)
      fill_in('Month', with: date_paid.month)
      fill_in('Year', with: date_paid.year)
    end
  end

  def fill_in_discretion_manager
    find('#application_discretion_manager_name', visible: false).fill_in(with: 'John Doe')
    find('#application_discretion_reason', visible: false).fill_in(with: 'Test reason')
  end
end
