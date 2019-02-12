And("I am on the reports page") do
  visit(reports_page.url)
end

When("I click on finance aggregated report") do
  expect(reports_page.content).to have_finance_aggregated_report_help
  reports_page.finance_aggregated_report
end

Then("I should be taken to finance aggregated report page") do
  expect(current_path).to include '/reports/finance_report'
end

When("I click on finance transactional report") do
  expect(reports_page.content).to have_finance_transactional_report_help
  reports_page.finance_transactional_report
end

Then("I should be taken to finance transactional report page") do
  expect(current_path).to include '/reports/finance_transactional_report'
end

When("I click on graphs") do
  expect(reports_page.content).to have_graphs_help
  reports_page.graphs
end

Then("I should be taken to the graphs page") do
  expect(current_path).to include '/reports/graphs'
end

When("I click on public submissions") do
  expect(reports_page.content).to have_public_submissions_help
  reports_page.public_submissions
end

Then("I should be taken to the public submissions page") do
  expect(current_path).to include '/reports/public'
end

When("I click on letters") do
  expect(reports_page.content).to have_letters_help
  reports_page.letters
end

Then("I should be taken to the letters page") do
  expect(current_path).to include '/letter_templates'
end

When("I click on raw data extract") do
  expect(reports_page.content).to have_raw_data_extract_help
  reports_page.raw_data_extract
end

Then("I should be taken to the raw data extract page") do
  expect(current_path).to include '/reports/raw_data'
end
