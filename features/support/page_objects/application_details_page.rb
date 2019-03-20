# rubocop:disable Metrics/AbcSize
class ApplicationDetailsPage < BasePage
  section :content, '#content' do
    element :header, 'h2', text: 'Application details'
    element :fee_label, 'label', text: 'Fee'
    element :application_fee, '#application_fee'
    element :fee_error, '.error', text: 'Enter the fee'
    element :jurisdiction_label, 'label', text: 'Jurisdiction'
    element :jurisdiction, 'input[value="1"]'
    element :jurisdiction_error, '.error', text: 'You must select a jurisdiction'
    element :date_received_label, 'label', text: 'Date application received'
    element :date_received_hint, '.hint', text: 'Use this format DD/MM/YYYY'
    element :application_date_received, '#application_date_received'
    element :application_date_error, '.error', text: 'Enter the date in this format DD/MM/YYYY'
    element :case_number_label, 'label', text: 'Case number'
    element :application_case_number, '#application_case_number'
    element :form_label, 'label', text: 'Form number'
    element :form_hint, 'label', text: 'You\'ll find this on the bottom of the form, for example C100 or ADM1A'
    element :form_input, '#application_form_name'
    element :form_error_message, '.error', text: 'Enter a valid form number'
    element :invalid_form_number_message, '.error', text: 'You entered the help with fees form number. Enter the number on your court or tribunal form'
  end

  def submit_with_fee_600
    content.application_fee.set '600'
    content.jurisdiction.click
    content.application_date_received.set Time.zone.today - 2.months
    content.form_input.set 'C100'
    content.application_case_number.set 'E71YX571'
    next_page
  end

  def submit_with_fee_300
    content.application_fee.set '300'
    content.jurisdiction.click
    content.application_date_received.set Time.zone.today - 2.months
    content.form_input.set 'C100'
    next_page
  end

  def submit_without_form_number
    content.application_fee.set '300'
    content.jurisdiction.click
    content.application_date_received.set Time.zone.today - 2.months
    next_page
  end
end
# rubocop:enable Metrics/AbcSize
