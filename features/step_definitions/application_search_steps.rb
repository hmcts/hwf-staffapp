Given("I am signed in as a user that has processed an application") do
  processed_eligable_application
end

Given("I am signed in as a user that has processed multiple applications") do
  processed_eligable_application
  processed_ineligable_application
end

When("I search for an application using a valid hwf reference") do
  expect(dashboard_page.content).to have_search_header
  dashboard_page.search_by_hwf_reference
end

Then("I see that application under search results") do
  expect(dashboard_page.content).to have_search_results_header
  expect(dashboard_page.content.search_results_group.found_application.text).to have_content 'PA19-000001'
end

Then("I should see the result for that full name") do
  expect(dashboard_page.content).to have_search_results_header
  expect(dashboard_page.content.search_results_group.found_application.text).to have_content 'John Christopher Smith'
end

When("I search for an application using a last name") do
  dashboard_page.search_by_last_name
end

When("I search for an application using a full name") do
  dashboard_page.search_by_full_name
end

When("there are multiple results for that name") do
  expect(dashboard_page.content).to have_search_results_header
  expect(dashboard_page.content.search_results_group.found_application.result_by_name.count).to eq 2
end

When("there is a single result for that full name") do
  expect(dashboard_page.content).to have_search_results_header
  expect(dashboard_page.content.search_results_group.found_application.result_by_name.count).to eq 1
end

Then("I should see a list of the results for that name") do
  expect(dashboard_page.content).to have_search_results_header
  expect(dashboard_page.content.search_results_group.found_application.result_by_name[0].text).to have_content 'Smith'
  expect(dashboard_page.content.search_results_group.found_application.result_by_name[1].text).to have_content 'Smith'
end

When("I search for an application using a case number") do
  dashboard_page.search_case_number
end

Then("I should see a list of the results with that case number") do
  expect(dashboard_page.content).to have_search_results_header
  expect(dashboard_page.content.search_results_group.found_application.text).to have_content 'E71YX571'
end

When("my search is invalid") do
  dashboard_page.search_invalid_reference
end

Then("I should see reference number is not recognised error message") do
  expect(dashboard_page.content).to have_no_search_results_header
  expect(dashboard_page.content).to have_no_results_found_error
end

When("I search leaving the input box blank") do
  dashboard_page.content.search_button.click
end

Then("I get the cannot be blank error message") do
  expect(dashboard_page.content).to have_no_search_results_header
  expect(dashboard_page.content).to have_cant_be_blank_error
end
