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
    element :letters_link, 'a', text: 'Old scheme templates'
    element :letters_help, 'dd', text: 'Display raw letters'
    element :raw_data_extract_link, 'a', text: 'Raw data extract'
    element :raw_data_extract_help, 'dd', text: 'Extract raw data by date for Analytical Services'
  end

  def finance_aggregated_report
    content.wait_until_finance_aggregated_report_link_visible
    content.finance_aggregated_report_link.click
  end

  def finance_transactional_report
    content.wait_until_finance_transactional_report_link_visible
    content.finance_transactional_report_link.click
  end

  def graphs
    content.wait_until_graphs_link_visible
    content.graphs_link.click
  end

  def public_submissions
    content.wait_until_public_submissions_link_visible
    content.public_submissions_link.click
  end

  def letters
    content.wait_until_letters_link_visible
    content.letters_link.click
  end

  def raw_data_extract
    content.wait_until_raw_data_extract_link_visible
    content.raw_data_extract_link.click
  end

end
