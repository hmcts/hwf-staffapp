# rubocop:disable Metrics/AbcSize
class ApplicationDetailsPage < BasePage
  set_url '/applications/2/details'

  section :content, '#content' do
    element :header, 'h2', text: 'Application details'
    element :fee_label, '.form-label', text: 'Fee'
    element :application_fee, '#application_fee'
    element :fee_error, '.error', text: 'Enter the fee'
    element :jurisdiction_label, '.form-label', text: 'Jurisdiction'
    element :application_jurisdiction, '#application_jurisdiction_id_1'
    element :jurisdiction_error, '.error', text: 'You must select a jurisdiction'
    element :date_received_label, '.form-label', text: 'Date application received'
    element :date_received_hint, '.hint', text: 'Use this format DD/MM/YYYY'
    element :application_date_received, '#application_date_received'
    element :application_date_error, '.error', text: 'Enter the date in this format DD/MM/YYYY'
    element :case_number_label, '.form-label', text: 'Case number'
    element :application_case_number, '#application_case_number'
  end

  def submit_with_fee_600
    content.application_fee.set '600'
    content.application_jurisdiction.click
    content.application_date_received.set Time.zone.today - 2.months
    content.application_case_number.set 'E71YX571'
    next_page
  end

  def submit_with_fee_300
    content.application_fee.set '300'
    content.application_jurisdiction.click
    content.application_date_received.set Time.zone.today - 2.months
    next_page
  end
end
# rubocop:enable Metrics/AbcSize
