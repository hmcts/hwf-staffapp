class GenerateReportPage < BasePage
  section :content, '#content' do
    element :aggregated_header, 'h1', text: 'Generate finance aggregated report'
    element :transactional_header, 'h1', text: 'Generate finance transactional report'
    element :public_application_stats_header, 'h1', text: 'Public application stats'
    element :raw_data_extract_header, 'h1', text: 'Raw data extract'
    element :generate_report_button, 'input[value="Generate report"]'
    element :date_from_label, 'label', text: 'Date From'
    elements :date_hint, '.hint', text: 'Use this format DD/MM/YYYY'
    element :aggregated_date_from, '#forms_finance_report_date_from'
    element :transactional_day_date_from, '#forms_report_finance_transactional_report_day_date_from'
    element :transactional_month_date_from, '#forms_report_finance_transactional_report_month_date_from'
    element :transactional_year_date_from, '#forms_report_finance_transactional_report_year_date_from'
    element :date_to_label, 'label', text: 'Date To'
    element :aggregated_date_to, '#forms_finance_report_date_to'
    element :transactional_day_date_to, '#forms_report_finance_transactional_report_day_date_to'
    element :transactional_month_date_to, '#forms_report_finance_transactional_report_month_date_to'
    element :transactional_year_date_to, '#forms_report_finance_transactional_report_year_date_to'
    element :blank_start_date_error, '.error', text: 'Please enter a start date'
    element :blank_end_date_error, '.error', text: 'Please enter an end date'
    element :date_range_error, '.error', text: 'The date range can\'t be longer than 2 years'
    element :filter_header, 'h2', text: 'Filters'
    element :jurisdiction, '.govuk-label', text: 'Jurisdiction'
    element :application_type, 'legend', text: 'Application type'
    element :benefit_label, '.govuk-label', text: 'Benefit'
    element :income_label, '.govuk-label', text: 'Income'
    element :refund, '.govuk-label', text: 'Refund'
    element :chart_one, '#chart-1'
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

  # rubocop:disable Metrics/AbcSize
  def enter_invalid_transactional_date
    date_from = Time.zone.today - 30.months
    date_to = Time.zone.today
    content.transactional_day_date_from.set date_from.day
    content.transactional_month_date_from.set date_from.month
    content.transactional_year_date_from.set date_from.year
    content.transactional_day_date_to.set date_to.day
    content.transactional_month_date_to.set date_to.month
    content.transactional_year_date_to.set date_to.year
    generate_report
  end
  # rubocop:enable Metrics/AbcSize
end
