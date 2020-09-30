# rubocop:disable Metrics/AbcSize
class ApplicationDetailsPage < BasePage
  section :content, '#main-content' do
    element :header, 'h1', text: 'Application details'
    element :jurisdiction_label, 'label', text: 'Jurisdiction'
    element :jurisdiction, '.govuk-radios__item'
    element :jurisdiction_error, '.error', text: 'You must select a jurisdiction'
    element :date_received_label, 'label', text: 'Date application received'
    element :date_received_hint, '.hint', text: 'Use this format DD/MM/YYYY'
    element :day_date_received, '#application_day_date_fee_paid'
    element :month_date_received, '#application_month_date_fee_paid'
    element :year_date_received, '#application_year_date_fee_paid'
    element :application_date_error, '.error', text: 'Enter the date in this format DD/MM/YYYY'
    element :form_label, 'label', text: 'Form number'
    element :form_hint, 'label', text: 'You\'ll find this on the bottom of the form, for example C100 or ADM1A'
    element :form_input, '#application_form_name'
    element :refund_case, '.govuk-label', text: 'This is a refund case'
    element :exceed_fee_limit_error, '.error', text: 'You need to enter an amount below £20,000'
    element :fee_blank_error, '.error', text: 'Enter a court or tribunal fee'
    element :form_error_message, '.error', text: 'Enter a valid form number'
    element :invalid_form_number_message, '.error', text: 'You entered the help with fees form number. Enter the number on the court or tribunal form.'
  end

  def go_to_application_details_page
    personal_details_page.submit_all_personal_details_ni
  end

  def date_application_received
    date_received = Time.zone.today - 2.months
    fill_in('Day', with: date_received.day)
    fill_in('Month', with: date_received.month)
    fill_in('Year', with: date_received.year)
  end

  def refund_case_date_after_application_received
    content.refund_case.click
    date_fee_paid = Time.zone.today - 1.month
    content.day_date_received.set date_fee_paid.day
    content.month_date_received.set date_fee_paid.month
    content.year_date_received.set date_fee_paid.year
  end

  def refund_case_with_valid_date
    content.refund_case.click
    date_fee_paid = Time.zone.today - 4.months
    content.day_date_received.set date_fee_paid.day
    content.month_date_received.set date_fee_paid.month
    content.year_date_received.set date_fee_paid.year
  end

  def submit_fee_100
    fill_in('How much is the court or tribunal fee?', with: '100')
    content.jurisdiction.click
    date_application_received
    content.form_input.set 'C100'
    next_page
  end

  def submit_fee_600
    fill_in('How much is the court or tribunal fee?', with: '600')
    content.jurisdiction.click
    date_application_received
    content.form_input.set 'C100'
    fill_in('Case number', with: 'E71YX571')
    next_page
  end

  def submit_fee_6000
    fill_in('How much is the court or tribunal fee?', with: '6000')
    content.jurisdiction.click
    date_application_received
    content.form_input.set 'C100'
    fill_in('Case number', with: 'E71YX571')
    next_page
  end

  def submit_fee_5000
    fill_in('How much is the court or tribunal fee?', with: '5000')
    content.jurisdiction.click
    date_application_received
    content.form_input.set 'C100'
    next_page
  end

  def submit_as_refund_case
    fill_in('How much is the court or tribunal fee?', with: '656.66', visible: false)
    content.jurisdiction.click
    date_application_received
    content.form_input.set 'C100'
    fill_in('Case number', with: 'E71YX571', visible: false)
    refund_case_with_valid_date
    next_page
  end

  def submit_fee_300
    fill_in('How much is the court or tribunal fee?', with: '300')
    content.jurisdiction.click
    date_application_received
    content.form_input.set 'C100'
    next_page
  end

  def submit_without_form_number
    fill_in('How much is the court or tribunal fee?', with: '300')
    content.jurisdiction.click
    date_application_received
    next_page
  end

  def submit_fee_10001
    fill_in('How much is the court or tribunal fee?', with: '10001')
    content.jurisdiction.click
    date_application_received
    content.form_input.set 'C100'
    fill_in('Case number', with: 'E71YX571')
    next_page
  end
end
# rubocop:enable Metrics/AbcSize
