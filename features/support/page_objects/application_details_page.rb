# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/ClassLength
class ApplicationDetailsPage < BasePage
  set_url_matcher %r{/applications/[0-9]+/details}

  section :content, '#main-content' do
    element :header, 'h1', text: 'Application details'
    element :fee_input, '#application_fee'
    element :jurisdiction_label, 'label', text: 'Jurisdiction'
    element :jurisdiction, '.govuk-radios__item label.govuk-radios__label'
    element :jurisdiction_error, '.error', text: 'You must select a jurisdiction'
    element :form_label, 'label', text: 'Form number'
    element :form_hint, 'label', text: 'You\'ll find this on the bottom of the form, for example C100 or ADM1A'
    element :form_input, '#application_form_name'
    element :refund_case, '.govuk-label', text: 'This is a refund case'
    element :day_date_received, '#application_day_date_fee_paid'
    element :month_date_received, '#application_month_date_fee_paid'
    element :year_date_received, '#application_year_date_fee_paid'
    element :exceed_fee_limit_error, '.error', text: 'You need to enter an amount below £20,000'
    element :fee_blank_error, '.error', text: 'Enter a court or tribunal fee'
    element :form_error_message, '.error', text: 'Enter a valid form number'
    element :invalid_form_number_message, '.error', text: 'You entered the help with fees form number. Enter the number on the court or tribunal form.'
    element :next, 'input[value="Next"]'
    element :delivery_manager_error, 'label', text: 'This fee was paid more than 3 months from the date received. Delivery Manager discretion must be applied to progress this application'
    element :probate_case, '.govuk-label', text: 'This is a probate case'
    section :probate_section, '#probate-only' do
      element :day_date_of_death, '#application_day_date_of_death'
      element :month_date_of_death, '#application_month_date_of_death'
      element :year_date_of_death, '#application_year_date_of_death'
      element :deceased_name, '#application_deceased_name'
    end
  end

  def date_application_received
    date_received = Time.zone.today - 2.months
    fill_in('Day', with: date_received.day)
    fill_in('Month', with: date_received.month)
    fill_in('Year', with: date_received.year)
  end

  def refund_case_with_valid_date
    content.refund_case.click
    date_fee_paid = Time.zone.today - 4.months
    content.day_date_received.set date_fee_paid.day
    content.month_date_received.set date_fee_paid.month
    content.year_date_received.set date_fee_paid.year
  end

  def refund_case_with_future_date
    content.refund_case.click
    date_fee_paid = Time.zone.today - 1.month
    content.day_date_received.set date_fee_paid.day
    content.month_date_received.set date_fee_paid.month
    content.year_date_received.set date_fee_paid.year
  end

  def refund_case_with_date_too_late
    content.refund_case.click
    date_fee_paid = Time.zone.today - 10.months
    content.day_date_received.set date_fee_paid.day
    content.month_date_received.set date_fee_paid.month
    content.year_date_received.set date_fee_paid.year
  end

  def fill_in_probate
    content.probate_case.click
    date_of_death = Time.zone.today - 1.month

    content.probate_section.day_date_of_death.set date_of_death.day
    content.probate_section.month_date_of_death.set date_of_death.month
    content.probate_section.year_date_of_death.set date_of_death.year
    content.probate_section.deceased_name.set 'John Doe'
  end

  def submit_fee_100
    fill_in('How much is the court or tribunal fee?', with: '100')
    content.jurisdiction.click
    content.form_input.set 'C100'
    click_next
  end

  def submit_fee_600
    fill_in('How much is the court or tribunal fee?', with: '600')
    content.jurisdiction.click
    content.form_input.set 'C100'
    fill_in('Case number', with: 'E71YX571')
    click_next
  end

  def submit_fee_600_pre_ucd
    fill_in('How much is the court or tribunal fee?', with: '600')
    content.jurisdiction.click
    date_application_received
    content.form_input.set 'C100'
    fill_in('Case number', with: 'E71YX571')
    click_next
  end

  def submit_fee_2000
    fill_in('How much is the court or tribunal fee?', with: '2000')
    content.jurisdiction.click
    content.form_input.set 'C100'
    fill_in('Case number', with: 'E71YX571')
    click_next
  end

  def submit_fee_6000
    fill_in('How much is the court or tribunal fee?', with: '6000')
    content.jurisdiction.click
    content.form_input.set 'C100'
    fill_in('Case number', with: 'E71YX571')
    click_next
  end

  def submit_as_refund_case_no_decimal
    fill_in('How much is the court or tribunal fee?', with: '650', visible: false)
    content.jurisdiction.click
    content.form_input.set 'C100'
    fill_in('Case number', with: 'E71YX571', visible: false)
    refund_case_with_valid_date
    click_next
  end

  def submit_as_refund_case
    fill_in('How much is the court or tribunal fee?', with: '656.66', visible: false)
    content.jurisdiction.click
    content.form_input.set 'C100'
    fill_in('Case number', with: 'E71YX571', visible: false)
    click_next
  end

  def submit_as_refund_case_pre_ucd
    fill_in('How much is the court or tribunal fee?', with: '656.66', visible: false)
    content.jurisdiction.click
    date_application_received
    content.form_input.set 'C100'
    fill_in('Case number', with: 'E71YX571', visible: false)
    refund_case_with_valid_date
    click_next
  end

  def submit_as_refund_case_date_too_late
    fill_in('How much is the court or tribunal fee?', with: '656.66', visible: false)
    content.jurisdiction.click
    content.form_input.set 'C100'
    fill_in('Case number', with: 'E71YX571', visible: false)
    refund_case_with_date_too_late
    click_next
  end

  def submit_as_refund_case_future_date
    fill_in('How much is the court or tribunal fee?', with: '656.66', visible: false)
    content.jurisdiction.click
    content.form_input.set 'C100'
    fill_in('Case number', with: 'E71YX571', visible: false)
    click_next
  end

  def submit_without_form_number
    fill_in('How much is the court or tribunal fee?', with: '300')
    content.jurisdiction.click
    click_next
  end

  def submit_fee_10001
    fill_in('How much is the court or tribunal fee?', with: '10001')
    content.jurisdiction.click
    content.form_input.set 'C100'
    fill_in('Case number', with: 'E71YX571')
    click_next
  end

  def submit_fee_600_blank_refund_date
    fill_in('How much is the court or tribunal fee?', with: '600')
    content.jurisdiction.click
    content.form_input.set 'C100'
    fill_in('Case number', with: 'E71YX571')
    click_next
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/ClassLength
