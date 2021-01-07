When("I click on generates reports") do
  dashboard_page.content.generate_reports_button.click
end

Then("I am taken to the reports page") do
  expect(reports_page).to be_displayed
end

When("I click on view office") do
  dashboard_page.content.view_offices.click
end

Then("I am taken to the offices page") do
  expect(offices_page).to be_displayed
end

Then("I should see all the responses by type graph") do
  expect(dashboard_page.content).to have_total_graph
end

Then("I should see checks by time of day graph") do
  expect(dashboard_page.content).to have_time_of_day_graph
end

When("I click on Court graphs") do
  dashboard_page.content.court_graphs.click
end

Then("I am taken to Court graphs page") do
  expect(court_graphs_page).to be_displayed
end
