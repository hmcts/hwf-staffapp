When("I click on next without making a selection") do
  next_page
end

Then("I should see select from one of the options error message") do
  expect(base_page.content).to have_select_from_list_error
end
