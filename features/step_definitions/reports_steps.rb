And("I am on the reports page") do
  dashboard_page.generate_reports
  expect(reports_page).to be_displayed
  expect(reports_page.content).to have_management_information_header
end

When("I click on finance aggregated report") do
  expect(reports_page.content).to have_finance_aggregated_report_help
  reports_page.finance_aggregated_report
end

Then("I should be taken to finance aggregated report page") do
  expect(page).to have_current_path(%r{/reports/finance_report})
end

When("I click on finance transactional report") do
  expect(reports_page.content).to have_finance_transactional_report_help
  reports_page.finance_transactional_report
end

Then("I should be taken to finance transactional report page") do
  expect(page).to have_current_path(%r{/reports/finance_transactional_report})
end

When("I click on graphs") do
  expect(reports_page.content).to have_graphs_help
  reports_page.graphs
end

Then("I should be taken to the graphs page") do
  expect(page).to have_current_path(%r{/reports/graphs})
end

When("I click on public submissions") do
  expect(reports_page.content).to have_public_submissions_help
  reports_page.public_submissions
end

Then("I should be taken to the public submissions page") do
  expect(page).to have_current_path(%r{/reports/public})
end

When("I click on letters") do
  expect(reports_page.content).to have_letters_help
  reports_page.letters
end

Then("I should be taken to the letters page") do
  expect(page).to have_current_path(%r{/letter_templates})
end

When("I click on raw data extract") do
  expect(reports_page.content).to have_raw_data_extract_help
  reports_page.raw_data_extract
end

Then("I should be taken to the raw data extract page") do
  expect(page).to have_current_path(%r{/reports/raw_data})
end

When("I click on income claims data extract") do
  expect(reports_page.content).to have_income_claims_data_extract_help
  reports_page.income_claims_data_extract
end

Then("I should be taken to the income claims data extract page") do
  expect(page).to have_current_path(%r{/report/income_claims_data})
end
