Given("I am signed in as a user that has processed an application") do
  processed_eligable_application
end

Given("I am signed in as a user that has processed multiple applications") do
  processed_eligable_application
  processed_ineligable_application
end

When("I search for an application using a valid hwf reference") do
  expect(application_search_page.content).to have_search_header
  application_search_page.search_by_hwf_reference
end

Then("I see that application under search results") do
  expect(application_search_page.content).to have_search_results_header
  expect(application_search_page.content.search_results_group.found_application.text).to have_content 'PA19-000001'
end

Then("I should see the result for that full name") do
  expect(application_search_page.content).to have_search_results_header
  expect(application_search_page.content.search_results_group.found_application.text).to have_content 'John Christopher Smith'
end

When("I search for an application using a last name") do
  application_search_page.search_by_last_name
end

When("I search for an application using a full name") do
  application_search_page.search_by_full_name
end

When("there is a single result for that full name") do
  expect(application_search_page.content).to have_search_results_header
  result = application_search_page.content.search_results_group.found_application.result
  expect(result[0].text).to include 'John Christopher Smith'
end

Then("I should see a list of the results for that last name") do
  expect(application_search_page.content).to have_search_results_header
  result = application_search_page.content.search_results_group.found_application.result
  expect(result[0].text).to include 'Smith'
  expect(result[1].text).to include 'Smith'
end

And("that there is one result for my office") do
  result = application_search_page.content.search_results_group.found_application.result
  expect(result[0].text).to include 'PA19'
  expect(result[1].text).to eq '1 result'
end

And("that there are two results for my office") do
  result = application_search_page.content.search_results_group.found_application.result
  expect(result[0].text).to include 'PA19'
  expect(result[1].text).to include 'PA19'
  expect(result[2].text).to eq '2 results'
end

When("I search for an application using a case number") do
  application_search_page.search_case_number('E71YX571')
end

Then("I should see there is a single result for that case number") do
  expect(application_search_page.content).to have_search_results_header
  result = application_search_page.content.search_results_group.found_application.result
  expect(result[0].text).to have_content 'E71YX571'
end

When("my search is invalid") do
  application_search_page.search_invalid_reference
end

Then("I should see reference number is not recognised error message") do
  expect(application_search_page.content).to have_no_search_results_header
  expect(application_search_page.content).to have_no_results_found_error
end

When("I search leaving the input box blank") do
  application_search_page.content.search_button.click
end

Then("I get the cannot be blank error message") do
  expect(application_search_page.content).to have_no_search_results_header
  expect(application_search_page.content).to have_cant_be_blank_error
end

Given("I have more than 20 search results") do
  application_search_page.paginated_search_results
end

Then("I see that it is paginated by 20 results per page") do
  result = application_search_page.content.search_results_group.found_application.result
  expect(result[25].text).to include '123…1516'
end

And("I can navigate forward a page") do
  application_search_page.pagination_next_page
  expect(application_search_page.content).to have_previous_page
end

And("I can navigate back a page") do
  application_search_page.pagination_previous_page
  expect(application_search_page.content).to have_no_previous_page
end
