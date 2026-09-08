class PartnerDetailsPage < BasePage
  set_url_matcher %r{/applications/[0-9]+/partner_informations}

  section :content, '#content' do
    element :header, 'h1', text: 'Personal details'
    element :partner_first_name, '#application_partner_first_name'
    element :partner_last_name, '#application_partner_last_name'
    element :partner_day_dob, '#application_day_date_of_birth'
    element :partner_month_dob, '#application_month_date_of_birth'
    element :partner_year_dob, '#application_year_date_of_birth'
    element :partner_ni_number, '#application_partner_ni_number'
    element :next, 'input[value="Next"]'
  end

  def full_name
    content.wait_until_partner_first_name_visible
    content.partner_first_name.set('John')
    content.partner_last_name.set('Smith')
  end

  def valid_dob
    content.partner_day_dob.set('10')
    content.partner_month_dob.set('02')
    content.partner_year_dob.set('1986')
  end

  def valid_ni
    content.partner_ni_number.set(Settings.dwp_mock.ni_number_yes.first)
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end

  def submit_partner_details
    full_name
    valid_dob
    valid_ni
    click_next
  end
end
