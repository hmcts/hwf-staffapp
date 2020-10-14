class ReportsPage < BasePage
  set_url '/reports'

  section :content, '#content' do
    element :management_information_header, 'h1', text: 'Management Information'
    element :finance_aggregated_report_link, 'a', text: 'Finance aggregated report'
    element :finance_aggregated_report_help, 'dd', text: 'Date delimited report of financial expenditure'
    element :finance_transactional_report_link, 'a', text: 'Finance transactional report'
    element :finance_transactional_report_help, 'dd', text: 'Date delimited transaction-level Finance report'
    element :graphs_link, 'a', text: 'Graphs'
    element :graphs_help, 'dd', text: '5 day graphs for benefit checks by business unit'
    element :public_submissions_link, 'a', text: 'Public submissions'
    element :public_submissions_help, 'dd', text: 'Track public submission data'
    element :letters_link, 'a', text: 'Letters'
    element :letters_help, 'dd', text: 'Display raw letters'
    element :raw_data_extract_link, 'a', text: 'Raw data extract'
    element :raw_data_extract_help, 'dd', text: 'Extract raw data by date for Analytical Services'
    element :income_claims_data_extract_link, 'a', text: 'Income claims data by court'
    element :income_claims_data_extract_help, 'dd', text: 'Extract income claims data by court and date'
  end

  def finance_aggregated_report
    content.finance_aggregated_report_link.click
  end

  def finance_transactional_report
    content.finance_transactional_report_link.click
  end

  def graphs
    content.graphs_link.click
  end

  def public_submissions
    content.public_submissions_link.click
  end

  def letters
    content.letters_link.click
  end

  def raw_data_extract
    content.raw_data_extract_link.click
  end

  def income_claims_data_extract
    content.income_claims_data_extract_link.click
  end
end
