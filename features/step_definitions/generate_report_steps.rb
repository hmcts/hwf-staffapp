Given("I am on the finance aggregated report page") do
  dashboard_page.generate_reports
  reports_page.finance_aggregated_report
  expect(current_path).to include '/reports/finance_report'
  expect(generate_report_page.content).to have_aggregated_header
end

When("I enter a valid date for finance aggregated reports") do
  generate_report_page.enter_valid_aggregated_date
end

When("I enter a valid date for finance transactional reports") do
  generate_report_page.enter_valid_transactional_date
end

Then("a finance aggregated report is downloaded") do
  date = Time.zone.today.strftime('%d/%m/%Y')
  expect(DownloadHelpers.download_content).to include date
  DownloadHelpers.clear_downloads
end

Then("a finance transactional report is downloaded") do
  date = Time.zone.today.strftime('%d/%m/%Y')
  expect(DownloadHelpers.download_content).to include date, 'Report Title:,Finance Transactional Report'
  DownloadHelpers.clear_downloads
end

When("I try and generate a report without entering dates") do
  generate_report_page.generate_report
end

Then("I should see enter dates error message") do
  expect(generate_report_page.content).to have_blank_start_date_error
  expect(generate_report_page.content).to have_blank_end_date_error
end

Given("I am on the finance transactional report page") do
  go_to_finance_transactional_report_page
  expect(current_path).to include '/reports/finance_transactional_report'
  expect(generate_report_page.content).to have_transactional_header
end

When("I enter a date range that exceeds two years") do
  generate_report_page.enter_invalid_transactional_date
end

Then("I should see date range exceeds two years error message") do
  expect(generate_report_page.content).to have_date_range_error
end
