When("I visit the admin dashboard page") do
  expect(dashboard_page).to be_displayed
end

When("I should be on the generate reports page") do
  expect(reports_page).to be_displayed
end