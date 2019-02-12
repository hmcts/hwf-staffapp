class GenerateReportPage < BasePage
  section :content, '#content' do
    element :aggregated_header, 'h2', text: 'Generate finance aggregated report'
    element :transactional_header, 'h2', text: 'Generate finance transactional report'
    element :generate_report_button, 'input[value="Generate report"]'
    element :date_from_label, 'label', text: 'Date From'
    elements :date_hint, '.hint', text: 'Use this format DD/MM/YYYY'
    element :aggregated_date_from, '#forms_finance_report_date_from'
    element :transactional_date_from, '#forms_report_finance_transactional_report_date_from'
    element :date_to_label, 'label', text: 'Date To'
    element :aggregated_date_to, '#forms_finance_report_date_to'
    element :transactional_date_to, '#forms_report_finance_transactional_report_date_to'
    element :blank_start_date_error, '.error', text: 'Please enter a start date'
    element :blank_end_date_error, '.error', text: 'Please enter an end date'
    element :date_range_error, '.error', text: 'The date range can\'t be longer than 2 years'
  end

  def generate_report
    content.generate_report_button.click
  end

  def enter_valid_aggregated_date
    content.aggregated_date_from.set Time.zone.today - 22.months
    content.aggregated_date_to.set Time.zone.today
    generate_report
  end

  def enter_valid_transactional_date
    content.transactional_date_from.set Time.zone.today - 22.months
    content.transactional_date_to.set Time.zone.today
    generate_report
  end

  def enter_invalid_transactional_date
    content.transactional_date_from.set Time.zone.today - 30.months
    content.transactional_date_to.set Time.zone.today
    generate_report
  end
end
